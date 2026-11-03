// ignore_for_file: deprecated_member_use, sort_constructors_first

import 'package:doctor_appointment_api/models/base/base_entity.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DoctorSchedule extends BaseEntity {
  DoctorSchedule({
    super.id,
    super.status,
    super.created,
    super.updated,
    super.version,
    this.doctorId,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.isAvailable = true,
  });
  ObjectId? doctorId;
  int? dayOfWeek;
  String? startTime;
  String? endTime;
  bool isAvailable;

  factory DoctorSchedule.fromMap(Map<String, dynamic> map) => DoctorSchedule(
    id: map['_id'] is ObjectId ? map['_id'] as ObjectId : null,
    status: map['status'] as bool? ?? true,
    created: map['created'] is DateTime ? map['created'] as DateTime : null,
    updated: map['updated'] is DateTime ? map['updated'] as DateTime : null,
    doctorId: map['doctorId'] is ObjectId ? map['doctorId'] as ObjectId : null,
    dayOfWeek: map['dayOfWeek'] as int?,
    startTime: map['startTime'] as String?,
    endTime: map['endTime'] as String?,
    isAvailable: map['isAvailable'] as bool? ?? true,
    version: map['version'] as int? ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'id': id?.toHexString(),
    'status': status,
    'doctorId': doctorId?.toHexString(),
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
    'isAvailable': isAvailable,
    'created': created?.toIso8601String(),
    'updated': updated?.toIso8601String(),
  };
}
