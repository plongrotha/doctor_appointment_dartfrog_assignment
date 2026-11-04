import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/controllers/specialty_controller.dart';

Future<Response> onRequest(RequestContext context, String id) {
  return context.read<SpecialtyController>().handle(context, id);
}
