import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../data/product_list_provider.dart';
import '../domain/product_list_repository.dart';
import 'state.dart';

sealed class ProductListEvent {
  const ProductListEvent();
}

final class ProductListEventInitialise extends ProductListEvent {}

final class ProductListEventSearch extends ProductListEvent {
  const ProductListEventSearch({required this.query});

  final String query;
}

final class ProductListEventLoadMore extends ProductListEvent {
  const ProductListEventLoadMore({required this.query});

  final String? query;
}

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  ProductListBloc() : super(const ProductListStateInitial()) {
    on<ProductListEventInitialise>(_onEventInitialise);
    on<ProductListEventSearch>(_onEventSearch);
    on<ProductListEventLoadMore>(_onEventLoadMore);
  }

  final logger = Logger('ProductListBloc');

  final repository = ProductListDataRepository(
    provider: ProductListDataProvider(),
  );

  Future<void> _onEventInitialise(
    ProductListEventInitialise event,
    Emitter<ProductListState> emit,
  ) async {
    try {
      emit(const ProductListStateInProgress());
      final data = await repository.fetchProductList();

      if (data == null) {
        emit(const ProductListStateFailure(exception: 'Data is missing'));
        return;
      }

      emit(ProductListStateSuccess(products: data));
    } on Exception catch (e) {
      logger.severe(e);
      emit(ProductListStateFailure(exception: e));
    }
  }

  Future<void> _onEventSearch(
    ProductListEventSearch event,
    Emitter<ProductListState> emit,
  ) async {
    try {
      emit(const ProductListStateInProgress());
      final data = await repository.searchProductList(query: event.query);

      if (data == null) {
        emit(const ProductListStateFailure(exception: 'Data is missing'));
        return;
      }

      emit(ProductListStateSuccess(products: data));
    } on Exception catch (e) {
      logger.severe(e);
      emit(ProductListStateFailure(exception: e));
    }
  }

  Future<void> _onEventLoadMore(
    ProductListEventLoadMore event,
    Emitter<ProductListState> emit,
  ) async {
    try {
      final currentState = state;
      final currentData = currentState is ProductListStateSuccess
          ? currentState.products
          : null;

      if (currentData == null) {
        emit(const ProductListStateFailure(exception: 'Data is missing'));
        return;
      }

      final skip = currentData.skip ?? 0;
      final total = currentData.total ?? 0;
      final limit = currentData.limit ?? 0;

      if (skip > total) {
        emit(
          ProductListStateSuccessMax(
            message: 'You have reached the end',
            products: currentData,
          ),
        );
        return;
      }

      emit(ProductListStateInProgress(products: currentData));

      final data = switch (event.query) {
        String() => await repository.searchProductList(
          query: event.query!,
          skip: skip + limit,
        ),
        null => await repository.fetchProductList(skip: skip + limit),
      };

      if (data == null) {
        emit(const ProductListStateFailure(exception: 'Data is missing'));
        return;
      }

      emit(ProductListStateSuccess(products: data));
    } on Exception catch (e) {
      logger.severe(e);
      emit(ProductListStateFailure(exception: e));
    }
  }
}
