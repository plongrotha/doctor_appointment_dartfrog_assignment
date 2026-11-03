// ignore_for_file: do_not_use_environment

import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/controllers/auth_controller.dart';
import 'package:doctor_appointment_api/database/mongo_database.dart';
import 'package:doctor_appointment_api/services/impl/auth_service_impl.dart';

Handler middleware(Handler handler) {
  return handler.use(
    provider<AuthController>(
      (context) => AuthController(
        authService: AuthServiceImpl(
          db: MongoDatabase.database,
          jwtSecret: const String.fromEnvironment(
            'JWT_SECRET',
            defaultValue: 'development-only-jwt-secret-change-this-value',
          ),
        ),
      ),
    ),
  );
}
