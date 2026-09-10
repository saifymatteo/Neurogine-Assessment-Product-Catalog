import 'package:logging/logging.dart';

import '../../../models/models.dart';
import '../data/product_list_provider.dart';

class ProductListDataRepository {
  const ProductListDataRepository({required this.provider});

  final ProductListDataProvider provider;

  Logger get _logger => Logger('ProductListDataRepository');

  Future<ProductList?> fetchProductList({int limit = 20, int skip = 0}) async {
    try {
      final rawData = await provider.readData(limit: limit, skip: skip);

      if (rawData is! Map<String, dynamic>) {
        _logger.warning('Incorrect data');
        return null;
      }

      return ProductList.fromJson(rawData);
    } catch (_) {
      rethrow;
    }
  }

  Future<ProductList?> searchProductList({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      if (query.isEmpty) {
        _logger.warning('Query cannot be empty');
        return null;
      }

      final rawData = await provider.searchData(
        query: query,
        limit: limit,
        skip: skip,
      );

      if (rawData is! Map<String, dynamic>) {
        _logger.warning('Incorrect data');
        return null;
      }

      return ProductList.fromJson(rawData);
    } catch (_) {
      rethrow;
    }
  }
}
