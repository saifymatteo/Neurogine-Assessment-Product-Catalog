import 'package:dio/dio.dart';

class NetworkService {
  final dio = Dio(BaseOptions(baseUrl: "https://dummyjson.com"));

  void dispose() {
    dio.close(force: true);
  }
}
