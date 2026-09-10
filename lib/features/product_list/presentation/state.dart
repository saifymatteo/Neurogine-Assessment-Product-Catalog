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
  const ProductListStateSuccess({required this.products});
  final ProductList products;
}

final class ProductListStateSuccessMax extends ProductListState {
  const ProductListStateSuccessMax({
    required this.message,
    required this.products,
  });
  final ProductList products;
  final String message;
}

final class ProductListStateFailure extends ProductListState {
  const ProductListStateFailure({required this.exception});
  final Object exception;
}
