// ignore_for_file: public_member_api_docs

import 'package:mongo_dart/mongo_dart.dart';

abstract class BaseEntity {
  BaseEntity({
    this.id,
    this.status = true,
    DateTime? created,
    DateTime? updated,
    this.createdById,
    this.updatedById,
    this.version = 0,
  }) : created = created ?? DateTime.now().toUtc(),
       updated = updated ?? DateTime.now().toUtc();
  ObjectId? id;

  bool status;

  DateTime? created;
  DateTime? updated;

  ObjectId? createdById;
  ObjectId? updatedById;

  int version;

  /// Convert common fields to a MongoDB document.
  Map<String, dynamic> toBaseMap() {
    return {
      if (id != null) '_id': id,
      'status': status,
      'created': created,
      'updated': updated,
      'createdById': createdById,
      'updatedById': updatedById,
      'version': version,
    };
  }
}
