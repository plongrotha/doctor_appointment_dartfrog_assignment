// ignore_for_file: sort_constructors_first, deprecated_member_use

import 'package:doctor_appointment_api/models/base/base_entity.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Review extends BaseEntity {
  Review({
    super.id,
    super.status,
    super.created,
    super.updated,
    super.version,
    this.patientId,
    this.doctorId,
    this.appointmentId,
    this.rating,
    this.comment,
  });
  ObjectId? patientId;
  ObjectId? doctorId;
  ObjectId? appointmentId;
  int? rating;
  String? comment;

  factory Review.fromMap(Map<String, dynamic> map) => Review(
    id: _id(map['_id']),
    status: map['status'] as bool? ?? true,
    created: _date(map['created']),
    updated: _date(map['updated']),
    patientId: _id(map['patientId']),
    doctorId: _id(map['doctorId']),
    appointmentId: _id(map['appointmentId']),
    rating: map['rating'] as int?,
    comment: map['comment'] as String?,
    version: map['version'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id?.toHexString(),
    'status': status,
    'patientId': patientId?.toHexString(),
    'doctorId': doctorId?.toHexString(),
    'appointmentId': appointmentId?.toHexString(),
    'rating': rating,
    'comment': comment,
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
