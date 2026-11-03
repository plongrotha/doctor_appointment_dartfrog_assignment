// ignore_for_file: public_member_api_docs

import 'package:doctor_appointment_api/models/user.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class AuthService {
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  });

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<void> logout({
    required String refreshToken,
  });

  Future<void> logoutAll({
    required ObjectId userId,
  });

  Future<void> forgotPassword({
    required String email,
  });

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<void> verifyEmail({
    required String token,
  });

  Future<User?> getCurrentUserProfile({required ObjectId userId});

  Future<User?> getCurrentUserProfileFromToken({
    required String accessToken,
  });

  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  });
}
