import '../../../models/models.dart';
import 'page.dart';

sealed class ProductDetailState {
  const ProductDetailState();
}

final class ProductDetailStateInitial extends ProductDetailState {
  const ProductDetailStateInitial();
}

final class ProductDetailStateInProgress extends ProductDetailState {
  const ProductDetailStateInProgress();
}

final class ProductDetailStateSuccess extends ProductDetailState {
  const ProductDetailStateSuccess({required this.product});

  final Product product;
}

final class ProductDetailStateFailure extends ProductDetailState {
  const ProductDetailStateFailure({required this.id, required this.exception});

  /// [id] comes from initialisation of page [ProductDetailPage]
  final int id;
  final Object exception;
}
