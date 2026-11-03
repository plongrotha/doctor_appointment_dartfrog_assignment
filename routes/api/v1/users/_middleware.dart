// ignore_for_file: prefer_const_declarations, do_not_use_environment

import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/controllers/user_controller.dart';
import 'package:doctor_appointment_api/database/mongo_database.dart';
import 'package:doctor_appointment_api/services/impl/auth_service_impl.dart';
import 'package:doctor_appointment_api/services/impl/user_service_impl.dart';

Handler middleware(Handler handler) {
  return handler.use(
    provider<UserController>(
      (context) {
        final db = MongoDatabase.database;
        final jwtSecret = const String.fromEnvironment(
          'JWT_SECRET',
          defaultValue: 'development-only-jwt-secret-change-this-value',
        );

        return UserController(
          userService: UserServiceImpl(db: db),
          authService: AuthServiceImpl(db: db, jwtSecret: jwtSecret),
        );
      },
    ),
  );
}
