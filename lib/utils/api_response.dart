// ignore_for_file: public_member_api_docs

import 'package:dart_frog/dart_frog.dart';

class ApiResponse {
  static Response success({
    required String message,
    dynamic result,
    int statusCode = 200,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'result': result,
        'response': {
          'code': statusCode,
          'message': message,
        },
      },
    );
  }

  static Response error({
    required String message,
    required int statusCode,
  }) {
    return success(
      message: message,
      statusCode: statusCode,
    );
  }
}
