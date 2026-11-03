// ignore_for_file: no_default_cases

import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/controllers/user_controller.dart';
import 'package:doctor_appointment_api/utils/api_response.dart';

Future<Response> onRequest(
  RequestContext context,
  String path,
) async {
  final controller = context.read<UserController>();
  final userId = path.split('/').where((part) => part.isNotEmpty).singleOrNull;

  if (userId == 'gender-dropdown') {
    if (context.request.method == HttpMethod.get) {
      return controller.getGenderDropdown();
    }
    return ApiResponse.error(
      message: 'Method not allowed.',
      statusCode: 405,
    );
  }

  if (userId == null) {
    if (context.request.method == HttpMethod.get) {
      return controller.list(context);
    }
    return ApiResponse.error(
      message: 'A user id is required.',
      statusCode: 400,
    );
  }

  switch (context.request.method) {
    case HttpMethod.get:
      return controller.getById(context, userId);
    case HttpMethod.put:
    case HttpMethod.patch:
      return controller.update(context, userId);
    case HttpMethod.delete:
      return controller.delete(context, userId);
    default:
      return ApiResponse.error(
        message: 'Method not allowed.',
        statusCode: 405,
      );
  }
}
