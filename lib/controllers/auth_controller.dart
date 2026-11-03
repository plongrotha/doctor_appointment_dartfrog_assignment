// ignore: duplicate_ignore
// ignore: lines_longer_than_80_chars
// ignore_for_file: lines_longer_than_80_chars, avoid_catching_errors, sort_constructors_first, public_member_api_docs

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:doctor_appointment_api/services/auth_service.dart';
import 'package:doctor_appointment_api/utils/api_response.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AuthController {
  final AuthService authService;

  AuthController({required this.authService});

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
    return ApiResponse.error(
      message: message,
      statusCode: statusCode,
    );
  }

  Future<Map<String, dynamic>?> _readBody(RequestContext context) async {
    try {
      final body = await context.request.body();
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return null;
    } on FormatException {
      return null;
    }
  }

  String? _requiredString(
    Map<String, dynamic> body,
    String key,
  ) {
    final value = body[key];

    if (value is! String || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  // register
  Future<Response> register(RequestContext context) async {
    final body = await _readBody(context);

    if (body == null) {
      return _error(
        message: 'Invalid  request body.',
        statusCode: 400,
      );
    }

    final firstName = _requiredString(body, 'firstName');
    final lastName = _requiredString(body, 'lastName');
    final email = _requiredString(body, 'email');
    final phone = _requiredString(body, 'phone');
    final dateOfBirth = _requiredString(body, 'dateOfBirth');
    final password = _requiredString(body, 'password');

    if (firstName == null ||
        lastName == null ||
        email == null ||
        password == null ||
        phone == null ||
        dateOfBirth == null) {
      return _error(
        message:
            'firstName, lastName, email, phone, dateOfBirth, and password are required.',
        statusCode: 400,
      );
    }

    try {
      final result = await authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: body['phone'] as String?,
      );

      return _success(
        message: 'Registration successful. Verify your email.',
        data: result,
        statusCode: 201,
      );
    } on ArgumentError catch (e) {
      return _error(
        message: e.message.toString(),
        statusCode: 400,
      );
    } on StateError catch (e) {
      return _error(
        message: e.message,
        statusCode: 409,
      );
    } catch (_) {
      return _error(
        message: 'Unable to register at this time.',
        statusCode: 500,
      );
    }
  }

  // login
  Future<Response> login(RequestContext context) async {
    final body = await _readBody(context);

    if (body == null) {
      return _error(
        message: 'Invalid JSON request body.',
        statusCode: 400,
      );
    }

    final email = _requiredString(body, 'email');
    final password = _requiredString(body, 'password');

    if (email == null || password == null) {
      return _error(
        message: 'Email and password are required.',
        statusCode: 400,
      );
    }

    try {
      final result = await authService.login(
        email: email,
        password: password,
      );

      return _success(
        message: result['verificationEmailSent'] == true
            ? 'Login successful. A verification email has been sent.'
            : 'Login successful.',
        data: result,
      );
    } on StateError {
      return _error(
        message: 'Invalid email or password.',
        statusCode: 401,
      );
    } catch (_) {
      return _error(
        message: 'Unable to log in at this time.',
        statusCode: 500,
      );
    }
  }

  // logout
  Future<Response> logout(RequestContext context) async {
    final body = await _readBody(context);

    if (body == null) {
      return _error(
        message: 'Invalid JSON request body.',
        statusCode: 400,
      );
    }

    final refreshToken = _requiredString(body, 'refreshToken');

    if (refreshToken == null) {
      return _error(
        message: 'refreshToken is required.',
        statusCode: 400,
      );
    }

    try {
      await authService.logout(refreshToken: refreshToken);

      return _success(message: 'Logout successful.');
    } catch (_) {
      return _error(
        message: 'Unable to log out.',
        statusCode: 500,
      );
    }
  }

  // Refresh tokens are credentials themselves, so this endpoint is public.
  Future<Response> refreshToken(RequestContext context) async {
    final body = await _readBody(context);

    if (body == null) {
      return _error(
        message: 'Invalid JSON request body.',
        statusCode: 400,
      );
    }

    final refreshToken = _requiredString(body, 'refreshToken');
    if (refreshToken == null) {
      return _error(
        message: 'refreshToken is required.',
        statusCode: 400,
      );
    }

    try {
      final tokens = await authService.refreshToken(
        refreshToken: refreshToken,
      );

      return _success(
        message: 'Token refreshed successfully.',
        data: tokens,
      );
    } on ArgumentError catch (error) {
      return _error(
        message: error.message.toString(),
        statusCode: 400,
      );
    } on StateError {
      return _error(
        message: 'The refresh token is invalid or expired.',
        statusCode: 401,
      );
    } catch (_) {
      return _error(
        message: 'Unable to refresh token.',
        statusCode: 500,
      );
    }
  }

  // logout all
  Future<Response> logoutAll(RequestContext context) async {
    final userId = context.read<ObjectId?>();

    if (userId == null) {
      return _error(
        message: 'Authentication required.',
        statusCode: 401,
      );
    }

    try {
      await authService.logoutAll(userId: userId);

      return _success(
        message: 'All sessions have been logged out.',
      );
    } catch (_) {
      return _error(
        message: 'Unable to log out all sessions.',
        statusCode: 500,
      );
    }
  }

  // 
  Future<Response> currentUserProfile(RequestContext context) async {
    final authorization = context.request.headers['authorization'];
    const prefix = 'Bearer ';

    if (authorization == null || !authorization.startsWith(prefix)) {
      return _error(
        message: 'Bearer access token is required.',
        statusCode: 401,
      );
    }

    final accessToken = authorization.substring(prefix.length).trim();
    if (accessToken.isEmpty) {
      return _error(
        message: 'Bearer access token is required.',
        statusCode: 401,
      );
    }

    try {
      final user = await authService.getCurrentUserProfileFromToken(
        accessToken: accessToken,
      );

      if (user == null) {
        return _error(
          message: 'User not found.',
          statusCode: 404,
        );
      }

      return _success(
        message: 'User profile retrieved successfully.',
        data: user.toJson(),
      );
    } on JWTException {
      return _error(
        message: 'Invalid or expired access token.',
        statusCode: 401,
      );
    } on FormatException {
      return _error(
        message: 'Invalid user id in access token.',
        statusCode: 401,
      );
    } catch (_) {
      return _error(
        message: 'Unable to retrieve user profile.',
        statusCode: 500,
      );
    }
  }

  // POST /auth/forgot-password
  Future<Response> forgotPassword(RequestContext context) async {
    final body = await _readBody(context);

    if (body == null) {
      return _error(
        message: 'Invalid JSON request body.',
        statusCode: 400,
      );
    }

    final email = _requiredString(body, 'email');

    if (email == null) {
      return _error(
        message: 'Email is required.',
        statusCode: 400,
      );
    }

    try {
      await authService.forgotPassword(email: email);

      // Same response whether the account exists or not.
      return _success(
        message:
            'If the account exists, password-reset instructions will be sent.',
      );
    } catch (_) {
      return _error(
        message: 'Unable to process the request.',
        statusCode: 500,
      );
    }
  }

  // POST /auth/reset-password
  Future<Response> resetPassword(RequestContext context) async {
    final body = await _readBody(context);

    if (body == null) {
      return _error(
        message: 'Invalid JSON request body.',
        statusCode: 400,
      );
    }

    final token = _requiredString(body, 'token');
    final newPassword = _requiredString(body, 'newPassword');

    if (token == null || newPassword == null) {
      return _error(
        message: 'token and newPassword are required.',
        statusCode: 400,
      );
    }

    try {
      await authService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      return _success(message: 'Password reset successful.');
    } on ArgumentError catch (e) {
      return _error(
        message: e.message.toString(),
        statusCode: 400,
      );
    } on StateError {
      return _error(
        message: 'The reset token is invalid or expired.',
        statusCode: 400,
      );
    } catch (_) {
      return _error(
        message: 'Unable to reset password.',
        statusCode: 500,
      );
    }
  }

  // POST /auth/verify-email
  Future<Response> verifyEmail(RequestContext context) async {
    final body = await _readBody(context);

    if (body == null) {
      return _error(
        message: 'Invalid JSON request body.',
        statusCode: 400,
      );
    }

    final token = _requiredString(body, 'token');

    if (token == null) {
      return _error(
        message: 'Verification token is required.',
        statusCode: 400,
      );
    }

    try {
      await authService.verifyEmail(token: token);

      return _success(message: 'Email verified successfully.');
    } on StateError {
      return _error(
        message: 'The verification token is invalid or expired.',
        statusCode: 400,
      );
    } catch (_) {
      return _error(
        message: 'Unable to verify email.',
        statusCode: 500,
      );
    }
  }
}
