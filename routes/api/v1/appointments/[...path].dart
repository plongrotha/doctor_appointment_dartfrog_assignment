import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/controllers/appointment_controller.dart';

Future<Response> onRequest(RequestContext context, String path) =>
    context.read<AppointmentController>().handle(
      context,
      path.split('/').where((part) => part.isNotEmpty).singleOrNull,
    );
