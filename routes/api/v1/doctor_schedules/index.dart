import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/controllers/doctor_schedule_controller.dart';

Future<Response> onRequest(RequestContext context) {
  return context.read<DoctorScheduleController>().handle(context, null);
}
