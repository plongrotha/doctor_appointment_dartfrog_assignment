import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/controllers/user_controller.dart';
import 'package:doctor_appointment_api/utils/api_response.dart';

Future<Response> onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Future.value(
      ApiResponse.error(
        message: 'Method not allowed.',
        statusCode: 405,
      ),
    );
  }
  return context.read<UserController>().list(context);
}
