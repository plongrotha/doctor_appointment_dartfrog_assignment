// ignore_for_file: public_member_api_docs

import 'package:doctor_appointment_api/models/user.dart';

abstract class UserService {
  Future<User?> getUserById({required String userId});

  Future<User?> getUserByEmail({required String email});

  Future<User?> getUserByPhone({required String phone});

  Future<List<User>> getAllUsers();

  Future<void> updateUser({
    required String userId,
    required Map<String, dynamic> updatedData,
  });

  Future<void> deleteUser({required String userId});
}
