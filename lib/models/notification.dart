// ignore_for_file: deprecated_member_use, sort_constructors_first

import 'package:doctor_appointment_api/models/base/base_entity.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Notification extends BaseEntity {
  Notification({
    super.id,
    super.status,
    super.created,
    super.updated,
    super.version,
    this.userId,
    this.title,
    this.message,
    this.type,
    this.readAt,
  });
  ObjectId? userId;
  String? title;
  String? message;
  String? type;
  DateTime? readAt;

  factory Notification.fromMap(Map<String, dynamic> map) => Notification(
    id: map['_id'] is ObjectId ? map['_id'] as ObjectId : null,
    status: map['status'] as bool? ?? true,
    created: map['created'] is DateTime ? map['created'] as DateTime : null,
    updated: map['updated'] is DateTime ? map['updated'] as DateTime : null,
    userId: map['userId'] is ObjectId ? map['userId'] as ObjectId : null,
    title: map['title'] as String?,
    message: map['message'] as String?,
    type: map['type'] as String?,
    readAt: map['readAt'] is DateTime ? map['readAt'] as DateTime : null,
    version: map['version'] as int? ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'id': id?.toHexString(),
    'status': status,
    'userId': userId?.toHexString(),
    'title': title,
    'message': message,
    'type': type,
    'readAt': readAt?.toIso8601String(),
    'created': created?.toIso8601String(),
    'updated': updated?.toIso8601String(),
  };
}
