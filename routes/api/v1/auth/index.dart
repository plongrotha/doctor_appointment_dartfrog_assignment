import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/utils/api_response.dart';

Response onRequest(RequestContext context) {
  return ApiResponse.error(
    statusCode: 404,
    message: 'Authentication endpoint not found.',
  );
}
