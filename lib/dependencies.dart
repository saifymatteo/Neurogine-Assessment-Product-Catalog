import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'cores/network/service.dart';

Future<void> initialiseDependencies() async {
  final logger = Logger.root;
  logger.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name} | ${record.time}: ${record.message}');
  });

  if (kDebugMode) {
    logger.level = Level.ALL;
  } else {
    logger.level = Level.INFO;
  }

  FlutterError.onError = (details) {
    logger.severe(details.exceptionAsString());
  };
  PlatformDispatcher.instance.onError = (error, _) {
    logger.severe(error.toString());
    return true;
  };

  logger.config('Initializing dependencies');
  GetIt.instance.registerSingleton<NetworkService>(
    NetworkService()..initialise(),
    dispose: (param) => param.dispose(),
  );
}
