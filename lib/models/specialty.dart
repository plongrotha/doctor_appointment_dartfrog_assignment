// ignore_for_file: deprecated_member_use, sort_constructors_first

import 'package:doctor_appointment_api/models/base/base_entity.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Specialty extends BaseEntity {
  Specialty({
    super.id,
    super.status,
    super.created,
    super.updated,
    super.version,
    this.name,
    this.description,
  });
  String? name;
  String? description;

  factory Specialty.fromMap(Map<String, dynamic> map) => Specialty(
    id: map['_id'] is ObjectId ? map['_id'] as ObjectId : null,
    status: map['status'] as bool? ?? true,
    created: map['created'] is DateTime ? map['created'] as DateTime : null,
    updated: map['updated'] is DateTime ? map['updated'] as DateTime : null,
    name: map['name'] as String?,
    description: map['description'] as String?,
    version: map['version'] as int? ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'id': id?.toHexString(),
    'status': status,
    'name': name,
    'description': description,
    'created': created?.toIso8601String(),
    'updated': updated?.toIso8601String(),
  };
}
