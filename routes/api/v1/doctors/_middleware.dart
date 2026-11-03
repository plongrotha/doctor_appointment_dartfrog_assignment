import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/controllers/doctor_controller.dart';
import 'package:doctor_appointment_api/database/mongo_database.dart';
import 'package:doctor_appointment_api/services/impl/auth_service_impl.dart';
import 'package:doctor_appointment_api/services/impl/doctor_service_impl.dart';

Handler middleware(Handler handler) => handler.use(provider<DoctorController>((_) {
  final db = MongoDatabase.database;
  return DoctorController(auth: AuthServiceImpl(db: db, jwtSecret: const String.fromEnvironment('JWT_SECRET', defaultValue: 'development-only-jwt-secret-change-this-value')), service: DoctorServiceImpl(db));
}));
