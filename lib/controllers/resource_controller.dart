// ignore_for_file: lines_longer_than_80_chars, no_default_cases, avoid_catching_errors, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:doctor_appointment_api/services/auth_service.dart';
import 'package:doctor_appointment_api/utils/api_response.dart';

typedef ResourceList = Future<List<Map<String, dynamic>>> Function();
typedef ResourceGet = Future<Map<String, dynamic>?> Function(String id);
typedef ResourceCreate =
    Future<Map<String, dynamic>> Function(Map<String, dynamic> data);
typedef ResourceUpdate =
    Future<Map<String, dynamic>?> Function(
      String id,
      Map<String, dynamic> data,
    );
typedef ResourceDelete = Future<void> Function(String id);
typedef ResourceSerializer =
    Map<String, dynamic> Function(Map<String, dynamic> data);

class ResourceController {
  ResourceController({
    required this.authService,
    required this.name,
    required this.list,
    required this.get,
    required this.create,
    required this.update,
    required this.delete,
    required this.serialize,
  });
  final AuthService authService;
  final String name;
  final ResourceList list;
  final ResourceGet get;
  final ResourceCreate create;
  final ResourceUpdate update;
  final ResourceDelete delete;
  final ResourceSerializer serialize;

  Future<bool> _authorized(RequestContext context) async {
    final header = context.request.headers['authorization'];
    if (header == null || !header.startsWith('Bearer ')) return false;
    final token = header.substring(7).trim();
    if (token.isEmpty) return false;
    return await authService.getCurrentUserProfileFromToken(
          accessToken: token,
        ) !=
        null;
  }

  Future<Map<String, dynamic>?> _body(RequestContext context) async {
    try {
      final value = jsonDecode(await context.request.body());
      return value is Map<String, dynamic> ? value : null;
    } on FormatException {
      return null;
    }
  }

  Future<Response> handle(RequestContext context, String? id) async {
    try {
      if (!await _authorized(context)) {
        return ApiResponse.error(
          message: 'Authentication required.',
          statusCode: 401,
        );
      }
      switch (context.request.method) {
        case HttpMethod.get:
          if (id == null) {
            final result = await list();
            return _ok(
              '$name retrieved successfully.',
              result.map(serialize).toList(),
            );
          }
          final item = await get(id);
          return item == null
              ? ApiResponse.error(message: '$name not found.', statusCode: 404)
              : _ok('$name retrieved successfully.', serialize(item));
        case HttpMethod.post:
          if (id != null) return _methodNotAllowed();
          final body = await _body(context);
          if (body == null)
            return ApiResponse.error(
              message: 'Invalid JSON request body.',
              statusCode: 400,
            );
          return _ok(
            '$name created successfully.',
            serialize(await create(body)),
            201,
          );
        case HttpMethod.put:
        case HttpMethod.patch:
          if (id == null) return _methodNotAllowed();
          final body = await _body(context);
          if (body == null)
            return ApiResponse.error(
              message: 'Invalid JSON request body.',
              statusCode: 400,
            );
          final item = await update(id, body);
          return item == null
              ? ApiResponse.error(message: '$name not found.', statusCode: 404)
              : _ok('$name updated successfully.', serialize(item));
        case HttpMethod.delete:
          if (id == null) return _methodNotAllowed();
          await delete(id);
          return _ok('$name deleted successfully.');
        default:
          return _methodNotAllowed();
      }
    } on JWTException {
      return ApiResponse.error(
        message: 'Invalid or expired access token.',
        statusCode: 401,
      );
    } on ArgumentError catch (error) {
      return ApiResponse.error(
        message: error.message.toString(),
        statusCode: 400,
      );
    } on StateError catch (error) {
      return ApiResponse.error(message: error.message, statusCode: 404);
    } catch (_) {
      return ApiResponse.error(
        message: 'Unable to process $name.',
        statusCode: 500,
      );
    }
  }

  Response _ok(String message, [dynamic data, int code = 200]) =>
      ApiResponse.success(message: message, result: data, statusCode: code);
  Response _methodNotAllowed() =>
      ApiResponse.error(message: 'Method not allowed.', statusCode: 405);
}
