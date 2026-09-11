import '../../../models/models.dart';

sealed class ProductListState {
  const ProductListState();
}

final class ProductListStateInitial extends ProductListState {
  const ProductListStateInitial();
}

final class ProductListStateInProgress extends ProductListState {
  const ProductListStateInProgress({this.products});

  final ProductList? products;
}

final class ProductListStateSuccess extends ProductListState {
  const ProductListStateSuccess({
    required this.products,
    this.hasReachedMax = false,
    this.message,
  });

  final ProductList products;
  final bool hasReachedMax;
  final String? message;
}

final class ProductListStateFailure extends ProductListState {
  const ProductListStateFailure({required this.exception, this.products});

  final ProductList? products;
  final Object exception;
}
