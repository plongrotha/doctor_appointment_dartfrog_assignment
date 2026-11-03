import 'package:doctor_appointment_api/controllers/resource_controller.dart';
import 'package:doctor_appointment_api/models/notification.dart';
import 'package:doctor_appointment_api/services/auth_service.dart';
import 'package:doctor_appointment_api/services/notification_service.dart';

class NotificationController extends ResourceController {
  NotificationController({
    required AuthService auth,
    required NotificationService service,
  }) : super(
         authService: auth,
         name: 'Notification',
         list: service.getAll,
         get: service.getById,
         create: service.create,
         update: service.update,
         delete: service.delete,
         serialize: (data) => Notification.fromMap(data).toJson(),
       );
}
