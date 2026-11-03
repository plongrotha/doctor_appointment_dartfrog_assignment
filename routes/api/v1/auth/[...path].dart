import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/controllers/auth_controller.dart';
import 'package:doctor_appointment_api/utils/api_response.dart';

Future<Response> onRequest(
  RequestContext context,
  String path,
) async {
  final endpoint = path.split('/').where((part) => part.isNotEmpty).lastOrNull;

  if (endpoint == 'me' && context.request.method == HttpMethod.get) {
    return context.read<AuthController>().currentUserProfile(context);
  }

  if (context.request.method != HttpMethod.post) {
    return ApiResponse.error(
      statusCode: 405,
      message: 'Method not allowed.',
    );
  }
  final controller = context.read<AuthController>();

  switch (endpoint) {
    case 'register':
      return controller.register(context);
    case 'login':
      return controller.login(context);
    case 'logout':
      return controller.logout(context);
    case 'refresh-token':
      return controller.refreshToken(context);
    case 'logout-all':
      return controller.logoutAll(context);
    case 'forgot-password':
      return controller.forgotPassword(context);
    case 'reset-password':
      return controller.resetPassword(context);
    case 'verify-email':
      return controller.verifyEmail(context);
    default:
      return ApiResponse.error(
        statusCode: 404,
        message: 'Authentication endpoint not found.',
      );
  }
}
