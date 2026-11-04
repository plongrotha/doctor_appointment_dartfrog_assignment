import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/controllers/user_controller.dart';

Future<Response> onRequest(RequestContext context, String id) {
  final controller = context.read<UserController>();
  switch (context.request.method) {
    case HttpMethod.get:
      return controller.getById(context, id);
    case HttpMethod.put:
    case HttpMethod.patch:
      return controller.update(context, id);
    case HttpMethod.delete:
      return controller.delete(context, id);
    default:
      return Future.value(
        Response.json(
          statusCode: 405,
          body: {
            'result': null,
            'response': {
              'code': 405,
              'message': 'Method not allowed.',
            },
          },
        ),
      );
  }
}
