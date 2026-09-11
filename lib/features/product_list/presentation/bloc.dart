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
    on<ProductListEventLoadMore>(_onEventLoadMore, transformer: _debounce());
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
        emit(const ProductListStateFailure(exception: 'Unable to fetch data'));
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

      // Guard against valid query
      if (event.query.isEmpty) {
        return _onEventInitialise(ProductListEventInitialise(), emit);
      }

      final data = await _repository.searchProductList(query: event.query);

      if (data == null) {
        emit(const ProductListStateFailure(exception: 'Unable to search'));
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
    final currentData = switch (state) {
      ProductListStateInitial() => null,
      ProductListStateInProgress(:final products) => products,
      ProductListStateSuccess(:final products) => products,
      ProductListStateFailure(:final products) => products,
    };

    if (currentData == null) {
      emit(
        const ProductListStateFailure(
          exception: 'Unable to fetch more, current data is missing',
        ),
      );
      return;
    }

    final skip = currentData.skip ?? 0;
    final total = currentData.total ?? 0;
    final limit = currentData.limit ?? 0;

    if (skip >= total) {
      emit(
        ProductListStateSuccess(
          products: currentData,
          hasReachedMax: true,
          message: 'You have reached the end',
        ),
      );
      return;
    }

    try {
      emit(ProductListStateInProgress(products: currentData));

      final hasQuery = event.query?.isNotEmpty ?? false;

      final data = switch (hasQuery) {
        true => await _repository.searchProductList(
          query: event.query!,
          skip: skip + limit,
        ),
        false => await _repository.fetchProductList(skip: skip + limit),
      };

      if (data == null) {
        emit(
          ProductListStateFailure(
            products: currentData,
            exception: 'Unable to fetch more data',
          ),
        );
        return;
      }

      emit(
        ProductListStateSuccess(
          products: data.copyWith(
            products: [...?currentData.products, ...?data.products],
          ),
        ),
      );
    } on Exception catch (e) {
      _logger.severe(e);
      emit(ProductListStateFailure(products: currentData, exception: e));
    }
  }
}
