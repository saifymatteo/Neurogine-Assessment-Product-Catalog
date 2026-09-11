import 'package:get_it/get_it.dart';
import '../../../cores/network/service.dart';

class ProductDetailDataProvider {
  final GetIt _getIt = GetIt.instance;

  Future<Object?> readData({required int id}) async {
    try {
      final dio = _getIt<NetworkService>().dio;

      final response = await dio.get<dynamic>('/products/$id');

      return response.data;
    } catch (_) {
      rethrow;
    }
  }
}
