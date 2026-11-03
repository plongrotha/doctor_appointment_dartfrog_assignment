// ignore_for_file: deprecated_member_use, sort_constructors_first

import 'package:doctor_appointment_api/models/base/base_entity.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Appointment extends BaseEntity {
  Appointment({
    super.id,
    super.status,
    super.created,
    super.updated,
    super.createdById,
    super.updatedById,
    super.version,
    this.patientId,
    this.doctorId,
    this.scheduleId,
    this.appointmentDate,
    this.notes,
  });

  ObjectId? patientId;
  ObjectId? doctorId;
  ObjectId? scheduleId;
  DateTime? appointmentDate;
  String? notes;

  factory Appointment.fromMap(Map<String, dynamic> map) => Appointment(
    id: _id(map['_id']),
    status: map['status'] as bool? ?? true,
    created: _date(map['created']),
    updated: _date(map['updated']),
    patientId: _id(map['patientId']),
    doctorId: _id(map['doctorId']),
    scheduleId: _id(map['scheduleId']),
    appointmentDate: _date(map['appointmentDate']),
    notes: map['notes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id?.toHexString(),
    'status': status,
    'patientId': patientId?.toHexString(),
    'doctorId': doctorId?.toHexString(),
    'scheduleId': scheduleId?.toHexString(),
    'appointmentDate': appointmentDate?.toIso8601String(),
    'notes': notes,
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
