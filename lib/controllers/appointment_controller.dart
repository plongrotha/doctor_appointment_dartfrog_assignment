// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs

import 'package:doctor_appointment_api/controllers/resource_controller.dart';
import 'package:doctor_appointment_api/models/appointment.dart';
import 'package:doctor_appointment_api/services/appointment_service.dart';
import 'package:doctor_appointment_api/services/auth_service.dart';

class AppointmentController extends ResourceController {
  AppointmentController({
    required AuthService auth,
    required AppointmentService service,
  }) : super(
         authService: auth,
         name: 'Appointment',
         list: service.getAll,
         get: service.getById,
         create: service.create,
         update: service.update,
         delete: service.delete,
         serialize: (data) => Appointment.fromMap(data).toJson(),
       );
}
