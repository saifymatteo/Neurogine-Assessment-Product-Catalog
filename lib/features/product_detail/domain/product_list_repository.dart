import 'package:logging/logging.dart';

import '../../../models/models.dart';
import '../data/product_detail_provider.dart';

class ProductDetailDataRepository {
  const ProductDetailDataRepository({required this.provider});

  final ProductDetailDataProvider provider;

  Logger get _logger => Logger('ProductDetailDataRepository');

  Future<Product?> fetchProductDetail({required int id}) async {
    try {
      final rawData = await provider.readData(id: id);

      if (rawData is! Map<String, dynamic>) {
        _logger.warning('Incorrect data');
        return null;
      }

      return Product.fromJson(rawData);
    } catch (_) {
      rethrow;
    }
  }
}
