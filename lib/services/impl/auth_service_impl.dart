// ignore_for_file: avoid_print, use_raw_strings, lines_longer_than_80_chars, deprecated_member_use, sort_constructors_first, public_member_api_docs

import 'dart:convert';
import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:doctor_appointment_api/models/user.dart';
import 'package:doctor_appointment_api/services/auth_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AuthServiceImpl implements AuthService {
  static const accessTokenLifetime = Duration(days: 5);
  static const refreshTokenLifetime = Duration(days: 30);

  final Db db;
  final String jwtSecret;

  AuthServiceImpl({
    required this.db,
    required this.jwtSecret,
  }) {
    if (jwtSecret.length < 32) {
      throw ArgumentError(
        'JWT_SECRET must contain at least 32 characters.',
      );
    }
  }

  DbCollection get _users => db.collection('users');

  DbCollection get _refreshTokens => db.collection('refresh_tokens');

  DbCollection get _passwordResets => db.collection('password_reset_tokens');

  DbCollection get _emailVerifications =>
      db.collection('email_verification_tokens');

  // Hash random tokens before storing them in MongoDB.
  String _hashToken(String token) {
    return sha256.convert(utf8.encode(token)).toString();
  }

  String _generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(
      32,
      (_) => random.nextInt(256),
    );

    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  void _validatePassword(String password) {
    if (password.length < 8) {
      throw ArgumentError(
        'Password must contain at least 8 characters.',
      );
    }
  }

  Map<String, dynamic> toDto(
    Map<String, dynamic> user,
  ) {
    return {
      'id': (user['_id'] as ObjectId).toHexString(),
      'firstName': user['firstName'],
      'lastName': user['lastName'],
      'email': user['email'],
      'phone': user['phone'],
      'avatar': user['avatar'],
      'gender': user['gender'],
      'emailVerifiedAt': user['emailVerifiedAt']?.toString(),
      'created': user['created']?.toString(),
    };
  }

  String _createAccessToken(Map<String, dynamic> user) {
    final jwt = JWT(
      {
        'sub': (user['_id'] as ObjectId).toHexString(),
        'email': user['email'],
        'type': 'access',
      },
    );

    return jwt.sign(
      SecretKey(jwtSecret),
      expiresIn: accessTokenLifetime,
    );
  }

  Future<Map<String, dynamic>> _issueTokens(
    Map<String, dynamic> user,
  ) async {
    final now = DateTime.now().toUtc();
    final refreshToken = _generateToken();

    await _refreshTokens.insertOne({
      'userId': user['_id'],
      'tokenHash': _hashToken(refreshToken),
      'createdAt': now,
      'expiresAt': now.add(refreshTokenLifetime),
      'revokedAt': null,
    });

    return {
      'accessToken': _createAccessToken(user),
      'refreshToken': refreshToken,
      'expiresIn': 5 * 24 * 60 * 60,
      'refreshExpiresIn': refreshTokenLifetime.inSeconds,
    };
  }

  // REGISTER
  @override
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    DateTime? dateOfBirth,
  }) async {
    _validatePassword(password);

    final normalizedEmail = _normalizeEmail(email);

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw ArgumentError('A valid email is required.');
    }

    final existing = await _users.findOne({
      'email': normalizedEmail,
    });

    if (existing != null) {
      throw StateError('An account with this email already exists.');
    }

    final now = DateTime.now().toUtc();

    final userDocument = <String, dynamic>{
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': normalizedEmail,
      'phone': phone?.trim(),
      'password': BCrypt.hashpw(
        password,
        BCrypt.gensalt(),
      ),
      'emailVerifiedAt': null,
      'status': true,
      'created': now,
      'updated': now,
      'version': 0,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };

    await _users.insertOne(userDocument);

    final user = await _users.findOne({
      'email': normalizedEmail,
    });

    if (user == null) {
      throw StateError('Could not load the created user.');
    }

    final verificationToken = _generateToken();

    await _emailVerifications.insertOne({
      'userId': user['_id'],
      'tokenHash': _hashToken(verificationToken),
      'createdAt': now,
      'expiresAt': now.add(const Duration(hours: 24)),
      'usedAt': null,
    });

    return {
      'user': toDto(user),
    };
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final user = await _users.findOne({
      'email': _normalizeEmail(email),
      'status': true,
    });

    // Use the same error for unknown email and wrong password.
    if (user == null) {
      throw StateError('Invalid email or password.');
    }

    final passwordHash = user['password'];

    if (passwordHash is! String || !BCrypt.checkpw(password, passwordHash)) {
      throw StateError('Invalid email or password.');
    }

    final verificationEmailSent = user['emailVerifiedAt'] == null;

    if (verificationEmailSent) {
      final now = DateTime.now().toUtc();
      final verificationToken = _generateToken();

      await _emailVerifications.deleteMany({
        'userId': user['_id'],
        'usedAt': null,
      });

      await _emailVerifications.insertOne({
        'userId': user['_id'],
        'tokenHash': _hashToken(verificationToken),
        'createdAt': now,
        'expiresAt': now.add(const Duration(hours: 24)),
        'usedAt': null,
      });
    }

    final tokens = await _issueTokens(user);

    return {
      ...tokens,
      'verificationEmailSent': verificationEmailSent,
    };
  }

  @override
  Future<void> logout({
    required String refreshToken,
  }) async {
    final tokenHash = _hashToken(refreshToken);

    await _refreshTokens.updateOne(
      {
        'tokenHash': tokenHash,
        'revokedAt': null,
      },
      {
        '\$set': {
          'revokedAt': DateTime.now().toUtc(),
        },
      },
    );
  }

  // LOGOUT ALL SESSIONS
  @override
  Future<void> logoutAll({
    required ObjectId userId,
  }) async {
    await _refreshTokens.updateMany(
      {
        'userId': userId,
        'revokedAt': null,
      },
      {
        '\$set': {
          'revokedAt': DateTime.now().toUtc(),
        },
      },
    );
  }

  // FORGOT PASSWORD
  @override
  Future<void> forgotPassword({
    required String email,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    final user = await _users.findOne({
      'email': normalizedEmail,
      'status': true,
    });

    // Don't reveal whether the email exists.
    if (user == null) return;

    final now = DateTime.now().toUtc();
    final token = _generateToken();

    await _passwordResets.deleteMany({
      'userId': user['_id'],
      'usedAt': null,
    });

    await _passwordResets.insertOne({
      'userId': user['_id'],
      'tokenHash': _hashToken(token),
      'createdAt': now,
      'expiresAt': now.add(const Duration(minutes: 15)),
      'usedAt': null,
    });
  }

  // RESET PASSWORD
  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _validatePassword(newPassword);

    final now = DateTime.now().toUtc();

    final reset = await _passwordResets.findOne({
      'tokenHash': _hashToken(token),
      'usedAt': null,
      'expiresAt': {'\$gt': now},
    });

    if (reset == null) {
      throw StateError(
        'The password reset token is invalid or expired.',
      );
    }

    final userId = reset['userId'] as ObjectId;

    await _users.updateOne(
      {
        '_id': userId,
        'status': true,
      },
      {
        '\$set': {
          'passwordHash': BCrypt.hashpw(
            newPassword,
            BCrypt.gensalt(),
          ),
          'updated': now,
        },
        '\$inc': {'version': 1},
      },
    );

    await _passwordResets.updateOne(
      {'_id': reset['_id']},
      {
        '\$set': {'usedAt': now},
      },
    );

    // Invalidate existing sessions after a password reset.
    await logoutAll(userId: userId);
  }

  // VERIFY EMAIL
  @override
  Future<void> verifyEmail({
    required String token,
  }) async {
    final now = DateTime.now().toUtc();

    final verification = await _emailVerifications.findOne({
      'tokenHash': _hashToken(token),
      'usedAt': null,
      'expiresAt': {'\$gt': now},
    });

    if (verification == null) {
      throw StateError(
        'The verification token is invalid or expired.',
      );
    }

    final userId = verification['userId'] as ObjectId;

    await _users.updateOne(
      {
        '_id': userId,
        'status': true,
        'emailVerifiedAt': null,
      },
      {
        '\$set': {
          'emailVerifiedAt': now,
          'updated': now,
        },
        '\$inc': {'version': 1},
      },
    );

    await _emailVerifications.updateOne(
      {'_id': verification['_id']},
      {
        '\$set': {'usedAt': now},
      },
    );
  }

  @override
  Future<User?> getCurrentUserProfile({
    required ObjectId userId,
  }) async {
    final user = await _users.findOne({
      '_id': userId,
      'status': true,
    });

    if (user == null) {
      return null;
    }

    return User.fromMap(user);
  }

  @override
  Future<User?> getCurrentUserProfileFromToken({
    required String accessToken,
  }) async {
    final jwt = JWT.verify(
      accessToken,
      SecretKey(jwtSecret),
      // issuer: 'mediqueue',
    );
    final payload = jwt.payload;

    if (payload is! Map<String, dynamic> || payload['type'] != 'access') {
      throw JWTException('Invalid access token.');
    }

    final subject = payload['sub'];
    if (subject is! String || subject.isEmpty) {
      throw JWTException('Access token does not contain a user id.');
    }

    final userId = ObjectId.parse(subject);
    return getCurrentUserProfile(userId: userId);
  }

  @override
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    if (refreshToken.trim().isEmpty) {
      throw ArgumentError('refreshToken is required.');
    }

    final now = DateTime.now().toUtc();
    final storedToken = await _refreshTokens.findOne({
      'tokenHash': _hashToken(refreshToken),
      'revokedAt': null,
      'expiresAt': {'\$gt': now},
    });

    print('Stored Token: $storedToken');

    if (storedToken == null) {
      throw StateError('The refresh token is invalid or expired.');
    }

    final userId = storedToken['userId'];
    if (userId is! ObjectId) {
      throw StateError('The refresh token is invalid.');
    }

    final user = await _users.findOne({
      '_id': userId,
      'status': true,
    });
    if (user == null) {
      throw StateError('The refresh token is invalid.');
    }

    // Refresh tokens are one-time credentials. Revoke the old token before
    // issuing a replacement so a replay cannot create another session.
    await _refreshTokens.updateOne(
      {
        '_id': storedToken['_id'],
        'revokedAt': null,
      },
      {
        '\$set': {'revokedAt': now},
      },
    );

    return _issueTokens(user);
  }
}
