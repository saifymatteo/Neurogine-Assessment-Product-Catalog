import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:product_catalog/cores/network/service.dart';
import 'package:product_catalog/dependencies.dart';
import 'package:product_catalog/features/product_detail/presentation/bloc.dart';
import 'package:product_catalog/features/product_detail/presentation/state.dart';

import 'fake_product_data.dart';

void main() {
  group(ProductDetailBloc, () {
    late Dio dio;
    late DioAdapter adapter;

    const productId = 2;

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

    blocTest<ProductDetailBloc, ProductDetailState>(
      'Page initialise',
      build: ProductDetailBloc.new,
      setUp: () => adapter.onGet(
        '/products/$productId',
        (server) => server.reply(
          200,
          fakeProductEyeShadow,
          delay: const Duration(milliseconds: 500),
        ),
      ),
      act: (bloc) =>
          bloc.add(const ProductDetailEventInitialise(id: productId)),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<ProductDetailStateInProgress>(),
        isA<ProductDetailStateSuccess>().having(
          (e) => e.product.id,
          'product.id',
          equals(productId),
        ),
      ],
    );

    blocTest<ProductDetailBloc, ProductDetailState>(
      'API failure',
      build: ProductDetailBloc.new,
      setUp: () => adapter.onGet(
        '/products/$productId',
        (server) => server.reply(500, {
          ['not', 'what', 'we', 'expect'],
        }, delay: const Duration(milliseconds: 500)),
      ),
      act: (bloc) =>
          bloc.add(const ProductDetailEventInitialise(id: productId)),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<ProductDetailStateInProgress>(),
        isA<ProductDetailStateFailure>().having(
          (e) => e.exception,
          'exception',
          isA<DioException>(),
        ),
      ],
    );
  });
}
