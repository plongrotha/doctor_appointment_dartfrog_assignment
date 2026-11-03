// ignore_for_file: deprecated_member_use, sort_constructors_first, public_member_api_docs

import 'package:doctor_appointment_api/models/user.dart';
import 'package:doctor_appointment_api/services/user_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UserServiceImpl implements UserService {
  final Db db;
  UserServiceImpl({required this.db});

  DbCollection get _users => db.collection('users');

  ObjectId _parseUserId(String userId) {
    try {
      return ObjectId.parse(userId);
    } on FormatException {
      throw ArgumentError.value(userId, 'userId', ' must be a valid ObjectId');
    }
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  @override
  Future<void> deleteUser({required String userId}) async {
    final id = _parseUserId(userId);
    final user = await _users.findOne({
      '_id': id,
      'status': true,
    });

    if (user == null) {
      throw StateError('User not found');
    }

    await _users.updateOne(
      {'_id': id},
      {
        r'$set': {
          'status': false,
          'updated': DateTime.now().toUtc(),
        },
        r'$inc': {'version': 1},
      },
    );
  }

  @override
  Future<List<User>> getAllUsers() async {
    final users = await _users.find({'status': true}).toList();
    return users.map(User.fromMap).toList();
  }

  @override
  Future<User?> getUserByEmail({required String email}) async {
    final user = await _users.findOne({
      'email': _normalizeEmail(email),
      'status': true,
    });
    return user == null ? null : User.fromMap(user);
  }

  @override
  Future<User?> getUserById({required String userId}) async {
    final user = await _users.findOne({
      '_id': _parseUserId(userId),
      'status': true,
    });
    return user == null ? null : User.fromMap(user);
  }

  @override
  Future<User?> getUserByPhone({required String phone}) async {
    final user = await _users.findOne({
      'phone': phone.trim(),
      'status': true,
    });
    return user == null ? null : User.fromMap(user);
  }

  @override
  Future<void> updateUser({
    required String userId,
    required Map<String, dynamic> updatedData,
  }) async {
    final allowedFields = {
      'firstName',
      'lastName',
      'email',
      'phone',
      'dateOfBirth',
      'password',
      'avatar',
      'gender',
      'emailVerifiedAt',
    };
    final unsupportedFields = updatedData.keys
        .where((key) => !allowedFields.contains(key))
        .toList();

    if (unsupportedFields.isNotEmpty) {
      throw ArgumentError(
        'Unsupported user fields: ${unsupportedFields.join(', ')}',
      );
    }
    if (updatedData.isEmpty) {
      throw ArgumentError('At least one user field is required.');
    }

    final id = _parseUserId(userId);
    final data = Map<String, dynamic>.from(updatedData);

    if (data.containsKey('email')) {
      final email = data['email'];
      if (email is! String || email.trim().isEmpty) {
        throw ArgumentError.value(
          email,
          'email',
          ' must be a non-empty string',
        );
      }
      data['email'] = _normalizeEmail(email);
    }
    if (data.containsKey('phone') && data['phone'] is String) {
      data['phone'] = (data['phone'] as String).trim();
    }

    final user = await _users.findOne({
      '_id': id,
      'status': true,
    });
    if (user == null) {
      throw StateError('User not found');
    }

    await _users.updateOne(
      {'_id': id},
      {
        r'$set': {
          ...data,
          'updated': DateTime.now().toUtc(),
        },
        r'$inc': {'version': 1},
      },
    );
  }
}
