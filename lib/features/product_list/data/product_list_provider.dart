import 'package:get_it/get_it.dart';
import '../../../cores/network/service.dart';

class ProductListDataProvider {
  final GetIt getIt = GetIt.instance;

  Future<Object?> readData({required int limit, required int skip}) async {
    final dio = getIt<NetworkService>().dio;

    try {
      final response = await dio.get<dynamic>(
        '/products',
        queryParameters: {'limit': limit, 'skip': skip},
      );

      return response.data;
    } catch (_) {
      rethrow;
    }
  }

  Future<Object?> searchData({
    required String query,
    required int limit,
    required int skip,
  }) async {
    final dio = getIt<NetworkService>().dio;

    try {
      final response = await dio.get<dynamic>(
        '/products/search',
        queryParameters: {'q': query, 'limit': limit, 'skip': skip},
      );

      return response.data;
    } catch (_) {
      rethrow;
    }
  }
}
