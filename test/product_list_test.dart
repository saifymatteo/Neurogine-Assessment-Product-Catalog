import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:product_catalog/cores/network/service.dart';
import 'package:product_catalog/dependencies.dart';
import 'package:product_catalog/features/product_list/presentation/bloc.dart';
import 'package:product_catalog/features/product_list/presentation/state.dart';
import 'package:product_catalog/models/models.dart';

import 'fake_product_data.dart';

void main() {
  group(ProductListBloc, () {
    late Dio dio;
    late DioAdapter adapter;

    setUp(() async {
      await initialiseDependencies();
      dio = GetIt.instance<NetworkService>().dio;
      adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;
    });

    tearDown(() async {
      GetIt.instance<NetworkService>().dispose();
      await GetIt.instance.reset();
    });

    blocTest<ProductListBloc, ProductListState>(
      'App initialisation',
      build: ProductListBloc.new,
      setUp: () => adapter.onGet(
        '/products',
        queryParameters: {'limit': 20, 'skip': 0},
        (server) => server.reply(
          200,
          fakeProductList,
          delay: const Duration(milliseconds: 500),
        ),
      ),
      act: (bloc) => bloc.add(ProductListEventInitialise()),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<ProductListStateInProgress>(),
        isA<ProductListStateSuccess>().having(
          (e) => e.products.products,
          'products',
          isNotEmpty,
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'API failure',
      build: ProductListBloc.new,
      setUp: () => adapter.onGet(
        '/products',
        queryParameters: {'limit': 20, 'skip': 0},
        (server) => server.reply(500, {
          ['not', 'what', 'we', 'expect'],
        }, delay: const Duration(milliseconds: 500)),
      ),
      act: (bloc) => bloc.add(ProductListEventInitialise()),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<ProductListStateInProgress>(),
        isA<ProductListStateFailure>().having(
          (e) => e.exception,
          'exception',
          isA<DioException>(),
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'Search "phone"',
      build: ProductListBloc.new,
      seed: () => const ProductListStateSuccess(products: ProductList()),
      setUp: () => adapter.onGet(
        '/products/search',
        queryParameters: {'q': 'phone', 'limit': 20, 'skip': 0},
        (server) => server.reply(
          200,
          fakeProductList,
          delay: const Duration(milliseconds: 500),
        ),
      ),
      act: (bloc) => bloc.add(const ProductListEventSearch(query: 'phone')),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<ProductListStateInProgress>(),
        isA<ProductListStateSuccess>().having(
          (e) => e.products.products,
          'products',
          isNotEmpty,
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'Search revert empty',
      build: ProductListBloc.new,
      seed: () => const ProductListStateSuccess(products: ProductList()),
      setUp: () => adapter.onGet(
        '/products',
        queryParameters: {'limit': 20, 'skip': 0},
        (server) => server.reply(
          200,
          fakeProductList,
          delay: const Duration(milliseconds: 500),
        ),
      ),
      act: (bloc) => bloc.add(const ProductListEventSearch(query: '')),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<ProductListStateInProgress>(),
        isA<ProductListStateSuccess>().having(
          (e) => e.products.products,
          'products',
          isNotEmpty,
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'Load more',
      build: ProductListBloc.new,
      seed: () => ProductListStateSuccess(
        products: ProductList(
          limit: 20,
          total: 40,
          skip: 0,
          products: [Product.fromJson(fakeProductMascara)],
        ),
      ),
      setUp: () => adapter.onGet(
        '/products',
        queryParameters: {'limit': 20, 'skip': 20},
        (server) => server.reply(
          200,
          fakeProductList,
          delay: const Duration(milliseconds: 500),
        ),
      ),
      act: (bloc) => bloc.add(const ProductListEventLoadMore(query: '')),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<ProductListStateInProgress>(),
        isA<ProductListStateSuccess>().having(
          (e) => e.products.products,
          'products',
          isNotEmpty,
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'Load more with query',
      build: ProductListBloc.new,
      seed: () => ProductListStateSuccess(
        products: ProductList(
          limit: 20,
          total: 40,
          skip: 0,
          products: [Product.fromJson(fakeProductMascara)],
        ),
      ),
      setUp: () => adapter.onGet(
        '/products/search',
        queryParameters: {'q': 'phone', 'limit': 20, 'skip': 20},
        (server) => server.reply(
          200,
          fakeProductList,
          delay: const Duration(milliseconds: 500),
        ),
      ),
      act: (bloc) => bloc.add(const ProductListEventLoadMore(query: 'phone')),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<ProductListStateInProgress>(),
        isA<ProductListStateSuccess>().having(
          (e) => e.products.products,
          'products',
          isNotEmpty,
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'Load more with error',
      build: ProductListBloc.new,
      seed: () => ProductListStateSuccess(
        products: ProductList(
          limit: 20,
          total: 40,
          skip: 0,
          products: [Product.fromJson(fakeProductMascara)],
        ),
      ),
      setUp: () => adapter.onGet(
        '/products',
        queryParameters: {'limit': 20, 'skip': 20},
        (server) => server.reply(500, {
          ['not', 'what', 'we', 'expect'],
        }, delay: const Duration(milliseconds: 500)),
      ),
      act: (bloc) => bloc.add(const ProductListEventLoadMore(query: '')),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<ProductListStateInProgress>(),
        isA<ProductListStateFailure>().having(
          (e) => e.exception,
          'exception',
          isA<DioException>(),
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'Load more reached max',
      build: ProductListBloc.new,
      seed: () => ProductListStateSuccess(
        products: ProductList(
          limit: 20,
          total: 40,
          skip: 40,
          products: [Product.fromJson(fakeProductMascara)],
        ),
      ),
      setUp: () => adapter.onGet(
        '/products',
        queryParameters: {'limit': 20, 'skip': 40},
        (server) => server.reply(
          200,
          fakeProductList,
          delay: const Duration(milliseconds: 500),
        ),
      ),
      act: (bloc) => bloc.add(const ProductListEventLoadMore(query: '')),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<ProductListStateSuccess>()
            .having((e) => e.message, 'message', isNotEmpty)
            .having((e) => e.hasReachedMax, 'hasReachedMax', true),
      ],
    );
  });
}
