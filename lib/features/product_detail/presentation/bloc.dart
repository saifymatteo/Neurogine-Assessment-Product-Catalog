import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../data/product_detail_provider.dart';
import '../domain/product_list_repository.dart';
import 'state.dart';

sealed class ProductDetailEvent {
  const ProductDetailEvent();
}

final class ProductDetailEventInitialise extends ProductDetailEvent {
  const ProductDetailEventInitialise({required this.id});

  final int id;
}

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc() : super(const ProductDetailStateInitial()) {
    on<ProductDetailEventInitialise>(_onEventInitialise);
  }

  final _logger = Logger('ProductDetailBloc');

  final _repository = ProductDetailDataRepository(
    provider: ProductDetailDataProvider(),
  );

  Future<void> _onEventInitialise(
    ProductDetailEventInitialise event,
    Emitter<ProductDetailState> emit,
  ) async {
    try {
      emit(const ProductDetailStateInProgress());
      final data = await _repository.fetchProductDetail(id: event.id);

      if (data == null) {
        emit(
          ProductDetailStateFailure(id: event.id, exception: 'Data is missing'),
        );
        return;
      }

      emit(ProductDetailStateSuccess(product: data));
    } on Exception catch (e) {
      _logger.severe(e);
      emit(ProductDetailStateFailure(id: event.id, exception: e));
    }
  }
}
