// ignore_for_file: lines_longer_than_80_chars, deprecated_member_use, sort_constructors_first, unused_import, avoid_catching_errors, public_member_api_docs

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:doctor_appointment_api/enums/gender.dart';
import 'package:doctor_appointment_api/models/user.dart';
import 'package:doctor_appointment_api/services/auth_service.dart';
import 'package:doctor_appointment_api/services/user_service.dart';
import 'package:doctor_appointment_api/utils/api_response.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UserController {
  final UserService userService;
  final AuthService authService;

  UserController({
    required this.userService,
    required this.authService,
  });

  Response _success({
    required String message,
    dynamic data,
    int statusCode = 200,
  }) {
    return ApiResponse.success(
      message: message,
      result: data,
      statusCode: statusCode,
    );
  }

  Response _error({
    required String message,
    required int statusCode,
  }) {
    return ApiResponse.error(message: message, statusCode: statusCode);
  }

  Future<User?> _authenticatedUser(RequestContext context) async {
    final authorization = context.request.headers['authorization'];
    const prefix = 'Bearer ';

    if (authorization == null || !authorization.startsWith(prefix)) {
      throw JWTException('Authentication required.');
    }

    final token = authorization.substring(prefix.length).trim();
    if (token.isEmpty) {
      throw JWTException('Authentication required.');
    }

    return authService.getCurrentUserProfileFromToken(accessToken: token);
  }

  Future<Map<String, dynamic>?> _readBody(RequestContext context) async {
    try {
      final decoded = jsonDecode(await context.request.body());
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  Response getGenderDropdown() {
    return _success(
      message: 'Gender options retrieved successfully.',
      data: Gender.values.map((gender) => gender.toJson()).toList(),
    );
  }

  bool _isOwner(User user, String userId) {
    return user.id?.toHexString() == userId;
  }

  Future<Response> list(RequestContext context) async {
    try {
      final currentUser = await _authenticatedUser(context);
      if (currentUser == null) {
        return _error(message: 'User not found.', statusCode: 401);
      }

      final users = await userService.getAllUsers();
      return _success(
        message: 'Users retrieved successfully.',
        data: users.map((user) => user.toJson()).toList(),
      );
    } on JWTException {
      return _error(
        message: 'Invalid or expired access token.',
        statusCode: 401,
      );
    } catch (_) {
      return _error(message: 'Unable to retrieve users.', statusCode: 500);
    }
  }

  Future<Response> getById(
    RequestContext context,
    String userId,
  ) async {
    try {
      final currentUser = await _authenticatedUser(context);
      if (currentUser == null) {
        return _error(message: 'User not found.', statusCode: 401);
      }

      final user = await userService.getUserById(userId: userId);
      if (user == null) {
        return _error(message: 'User not found.', statusCode: 404);
      }

      return _success(
        message: 'User retrieved successfully.',
        data: user.toJson(),
      );
    } on JWTException {
      return _error(
        message: 'Invalid or expired access token.',
        statusCode: 401,
      );
    } on FormatException {
      return _error(message: 'Invalid user id.', statusCode: 400);
    } on ArgumentError {
      return _error(message: 'Invalid user id.', statusCode: 400);
    } catch (_) {
      return _error(message: 'Unable to retrieve user.', statusCode: 500);
    }
  }

  Future<Response> update(
    RequestContext context,
    String userId,
  ) async {
    try {
      final currentUser = await _authenticatedUser(context);
      if (currentUser == null) {
        return _error(message: 'User not found.', statusCode: 401);
      }
      if (!_isOwner(currentUser, userId)) {
        return _error(
          message: 'You can only update your own profile.',
          statusCode: 403,
        );
      }

      final body = await _readBody(context);
      if (body == null) {
        return _error(message: 'Invalid JSON request body.', statusCode: 400);
      }

      // Password changes belong to the reset-password flow.
      body.remove('password');
      if (body.isEmpty) {
        return _error(
          message: 'At least one profile field is required.',
          statusCode: 400,
        );
      }

      await userService.updateUser(userId: userId, updatedData: body);
      final user = await userService.getUserById(userId: userId);

      return _success(
        message: 'User updated successfully.',
        data: user?.toJson(),
      );
    } on JWTException {
      return _error(
        message: 'Invalid or expired access token.',
        statusCode: 401,
      );
    } on FormatException {
      return _error(message: 'Invalid user id.', statusCode: 400);
    } on ArgumentError catch (error) {
      return _error(message: error.message.toString(), statusCode: 400);
    } on StateError catch (error) {
      return _error(message: error.message, statusCode: 404);
    } catch (_) {
      return _error(message: 'Unable to update user.', statusCode: 500);
    }
  }

  Future<Response> delete(
    RequestContext context,
    String userId,
  ) async {
    try {
      final currentUser = await _authenticatedUser(context);
      if (currentUser == null) {
        return _error(message: 'User not found.', statusCode: 401);
      }
      if (!_isOwner(currentUser, userId)) {
        return _error(
          message: 'You can only delete your own account.',
          statusCode: 403,
        );
      }

      await userService.deleteUser(userId: userId);
      return _success(message: 'User deleted successfully.');
    } on JWTException {
      return _error(
        message: 'Invalid or expired access token.',
        statusCode: 401,
      );
    } on FormatException {
      return _error(message: 'Invalid user id.', statusCode: 400);
    } on ArgumentError {
      return _error(message: 'Invalid user id.', statusCode: 400);
    } on StateError catch (error) {
      return _error(message: error.message, statusCode: 404);
    } catch (_) {
      return _error(message: 'Unable to delete user.', statusCode: 500);
    }
  }
}
