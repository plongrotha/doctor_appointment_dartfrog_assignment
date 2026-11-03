import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/controllers/specialty_controller.dart';
import 'package:doctor_appointment_api/database/mongo_database.dart';
import 'package:doctor_appointment_api/services/impl/auth_service_impl.dart';
import 'package:doctor_appointment_api/services/impl/specialty_service_impl.dart';

Handler middleware(Handler handler) => handler.use(provider<SpecialtyController>((_) {
  final db = MongoDatabase.database;
  return SpecialtyController(auth: AuthServiceImpl(db: db, jwtSecret: const String.fromEnvironment('JWT_SECRET', defaultValue: 'development-only-jwt-secret-change-this-value')), service: SpecialtyServiceImpl(db));
}));
