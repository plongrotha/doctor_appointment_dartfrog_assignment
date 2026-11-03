import 'package:doctor_appointment_api/controllers/resource_controller.dart';
import 'package:doctor_appointment_api/models/specialty.dart';
import 'package:doctor_appointment_api/services/auth_service.dart';
import 'package:doctor_appointment_api/services/specialty_service.dart';

class SpecialtyController extends ResourceController {
  SpecialtyController({
    required AuthService auth,
    required SpecialtyService service,
  }) : super(
         authService: auth,
         name: 'Specialty',
         list: service.getAll,
         get: service.getById,
         create: service.create,
         update: service.update,
         delete: service.delete,
         serialize: (data) => Specialty.fromMap(data).toJson(),
       );
}
