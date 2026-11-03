import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_swagger/dart_frog_swagger.dart';

Handler middleware(Handler handler) {
  return handler.use(
    swaggerMiddleware(
      // ignore: avoid_redundant_argument_values
      docsRoute: '/docs',
      title: 'Doctor Appointment API',

      // ignore: avoid_redundant_argument_values
      jsonRoute: '/openapi.json',

      // ignore: avoid_redundant_argument_values
      jsonAssetPath: 'build/openapi.json',
      projectRoot: '.',
    ),
  );
}

// run to build the openapi.json file
// dart run dart_frog_swagger
