import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:stream_transform/stream_transform.dart';

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
    on<ProductListEventSearch>(_onEventSearch, transformer: _debounce());
    on<ProductListEventLoadMore>(_onEventLoadMore);
  }

  final _logger = Logger('ProductListBloc');

  final _repository = ProductListDataRepository(
    provider: ProductListDataProvider(),
  );

  EventTransformer<T> _debounce<T>() {
    return (events, mapper) =>
        events.debounce(const Duration(milliseconds: 300)).switchMap(mapper);
  }

  Future<void> _onEventInitialise(
    ProductListEventInitialise event,
    Emitter<ProductListState> emit,
  ) async {
    try {
      emit(const ProductListStateInProgress());
      final data = await _repository.fetchProductList();

      if (data == null) {
        emit(const ProductListStateFailure(exception: 'Data is missing'));
        return;
      }

      emit(ProductListStateSuccess(products: data));
    } on Exception catch (e) {
      _logger.severe(e);
      emit(ProductListStateFailure(exception: e));
    }
  }

  Future<void> _onEventSearch(
    ProductListEventSearch event,
    Emitter<ProductListState> emit,
  ) async {
    try {
      emit(const ProductListStateInProgress());

      if (event.query.isEmpty) {
        return _onEventInitialise(ProductListEventInitialise(), emit);
      }

      final data = await _repository.searchProductList(query: event.query);

      if (data == null) {
        emit(const ProductListStateFailure(exception: 'Data is missing'));
        return;
      }

      emit(ProductListStateSuccess(products: data));
    } on Exception catch (e) {
      _logger.severe(e);
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

      if (skip >= total) {
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
        String() => await _repository.searchProductList(
          query: event.query!,
          skip: skip + limit,
        ),
        null => await _repository.fetchProductList(skip: skip + limit),
      };

      if (data == null) {
        emit(const ProductListStateFailure(exception: 'Data is missing'));
        return;
      }

      emit(ProductListStateSuccess(products: data));
    } on Exception catch (e) {
      _logger.severe(e);
      emit(ProductListStateFailure(exception: e));
    }
  }
}
