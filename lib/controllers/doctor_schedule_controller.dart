// ignore_for_file: public_member_api_docs

import 'package:doctor_appointment_api/controllers/resource_controller.dart';
import 'package:doctor_appointment_api/models/doctor_schedule.dart';
import 'package:doctor_appointment_api/services/auth_service.dart';
import 'package:doctor_appointment_api/services/doctor_schedule_service.dart';

class DoctorScheduleController extends ResourceController {
  DoctorScheduleController({
    required AuthService auth,
    required DoctorScheduleService service,
  }) : super(
         authService: auth,
         name: 'Doctor schedule',
         list: service.getAll,
         get: service.getById,
         create: service.create,
         update: service.update,
         delete: service.delete,
         serialize: (data) => DoctorSchedule.fromMap(data).toJson(),
       );
}
