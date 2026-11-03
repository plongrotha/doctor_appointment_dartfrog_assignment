// ignore: lines_longer_than_80_chars
// ignore_for_file: deprecated_member_use, sort_constructors_first, public_member_api_docs

import 'package:doctor_appointment_api/models/base/base_entity.dart';
import 'package:mongo_dart/mongo_dart.dart';

class User extends BaseEntity {
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? dateOfBirth;
  String? password;
  String? avatar;
  String? gender;
  DateTime? emailVerifiedAt;

  User({
    super.id,
    super.status,
    super.created,
    super.updated,
    super.createdById,
    super.updatedById,
    super.version,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.password,
    this.avatar,
    this.gender,
    this.emailVerifiedAt,
  });

  /// Convert the model into a MongoDB document.
  Map<String, dynamic> toMap() {
    return {
      ...toBaseMap(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'password': password,
      'avatar': avatar,
      'gender': gender,
      'emailVerifiedAt': emailVerifiedAt,
    };
  }

  /// Convert the model into a safe API response.
  Map<String, dynamic> toJson() {
    return {
      'id': id?.toHexString(),
      'status': status,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'avatar': avatar,
      'gender': gender,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }

  /// Create a User from a MongoDB document or JSON map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] is ObjectId
          ? map['_id'] as ObjectId
          : map['id'] is String
          ? ObjectId.parse(map['id'] as String)
          : null,
      status: map['status'] as bool? ?? true,
      created: _parseDate(map['created']),
      updated: _parseDate(map['updated']),
      createdById: _parseObjectId(map['createdById']),
      updatedById: _parseObjectId(map['updatedById']),
      version: map['version'] as int? ?? 0,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      password: map['password'] as String?,
      avatar: map['avatar'] as String?,
      gender: map['gender'] as String?,
      emailVerifiedAt: _parseDate(map['emailVerifiedAt']),
    );
  }

  static ObjectId? _parseObjectId(dynamic value) {
    if (value is ObjectId) return value;
    if (value is String && value.isNotEmpty) {
      return ObjectId.parse(value);
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
