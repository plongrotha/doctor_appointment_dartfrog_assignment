import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/controllers/specialty_controller.dart';

Future<Response> onRequest(RequestContext context, String path) =>
    context.read<SpecialtyController>().handle(
      context,
      path.split('/').where((part) => part.isNotEmpty).singleOrNull,
    );
