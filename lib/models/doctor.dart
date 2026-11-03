// ignore_for_file: deprecated_member_use, sort_constructors_first

import 'package:doctor_appointment_api/models/base/base_entity.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Doctor extends BaseEntity {
  Doctor({
    super.id,
    super.status,
    super.created,
    super.updated,
    super.version,
    this.userId,
    this.specialtyId,
    this.bio,
    this.consultationFee,
  });
  ObjectId? userId;
  ObjectId? specialtyId;
  String? bio;
  num? consultationFee;

  factory Doctor.fromMap(Map<String, dynamic> map) => Doctor(
    id: _id(map['_id']),
    status: map['status'] as bool? ?? true,
    created: _date(map['created']),
    updated: _date(map['updated']),
    userId: _id(map['userId']),
    specialtyId: _id(map['specialtyId']),
    bio: map['bio'] as String?,
    consultationFee: map['consultationFee'] as num?,
    version: map['version'] as int? ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'id': id?.toHexString(),
    'status': status,
    'userId': userId?.toHexString(),
    'specialtyId': specialtyId?.toHexString(),
    'bio': bio,
    'consultationFee': consultationFee,
    'created': created?.toIso8601String(),
    'updated': updated?.toIso8601String(),
  };
  static ObjectId? _id(dynamic value) => value is ObjectId
      ? value
      : value is String
      ? ObjectId.parse(value)
      : null;
  static DateTime? _date(dynamic value) => value is DateTime
      ? value
      : value is String
      ? DateTime.tryParse(value)
      : null;
}
