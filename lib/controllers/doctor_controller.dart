// ignore_for_file: public_member_api_docs

import 'package:doctor_appointment_api/controllers/resource_controller.dart';
import 'package:doctor_appointment_api/models/doctor.dart';
import 'package:doctor_appointment_api/services/auth_service.dart';
import 'package:doctor_appointment_api/services/doctor_service.dart';

class DoctorController extends ResourceController {
  DoctorController({required AuthService auth, required DoctorService service})
    : super(
        authService: auth,
        name: 'Doctor',
        list: service.getAll,
        get: service.getById,
        create: service.create,
        update: service.update,
        delete: service.delete,
        serialize: (data) => Doctor.fromMap(data).toJson(),
      );
}
