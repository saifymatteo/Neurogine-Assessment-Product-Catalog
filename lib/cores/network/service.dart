import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

class NetworkService {
  final _logger = Logger('NetworkService');

  final dio = Dio();

  void initialise() {
    dio.options.baseUrl = 'https://dummyjson.com';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.info(options.uri);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.info(response);
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.severe(error);
          return handler.next(error);
        },
      ),
    );
  }

  void dispose() {
    dio.close(force: true);
  }
}
