import 'package:mongo_dart/mongo_dart.dart';

class MongoCrudService {
  MongoCrudService(this.db, this.collectionName, this.fields);
  final Db db;
  final String collectionName;
  final Set<String> fields;

  DbCollection get collection => db.collection(collectionName);

  ObjectId id(String value) {
    try {
      return ObjectId.parse(value);
    } on FormatException {
      throw ArgumentError.value(value, 'id', 'must be a valid ObjectId');
    }
  }

  Future<List<Map<String, dynamic>>> all() async =>
      collection.find({'status': true}).toList();

  Future<Map<String, dynamic>?> one(String value) async =>
      collection.findOne({'_id': id(value), 'status': true});

  Future<Map<String, dynamic>> create(Map<String, dynamic> input) async {
    final data = _clean(input);
    final now = DateTime.now().toUtc();
    final objectId = ObjectId();
    data.addAll({
      '_id': objectId,
      'status': true,
      'created': now,
      'updated': now,
      'version': 0,
    });
    await collection.insertOne(data);
    return (await collection.findOne({'_id': objectId})) ?? data;
  }

  Future<Map<String, dynamic>?> update(
    String value,
    Map<String, dynamic> input,
  ) async {
    final objectId = id(value);
    final data = _clean(input);
    if (data.isEmpty) throw ArgumentError('At least one field is required.');
    final existing = await collection.findOne({
      '_id': objectId,
      'status': true,
    });
    if (existing == null) return null;
    await collection.updateOne(
      {'_id': objectId, 'status': true},
      {
        r'$set': {...data, 'updated': DateTime.now().toUtc()},
        r'$inc': {'version': 1},
      },
    );
    return collection.findOne({'_id': objectId, 'status': true});
  }

  Future<bool> remove(String value) async {
    final objectId = id(value);
    final existing = await collection.findOne({
      '_id': objectId,
      'status': true,
    });
    if (existing == null) return false;
    await collection.updateOne(
      {'_id': objectId, 'status': true},
      {
        r'$set': {'status': false, 'updated': DateTime.now().toUtc()},
        r'$inc': {'version': 1},
      },
    );
    return true;
  }

  Map<String, dynamic> _clean(Map<String, dynamic> input) {
    final data = <String, dynamic>{};
    for (final entry in input.entries) {
      if (!fields.contains(entry.key)) {
        throw ArgumentError('Unsupported field: ${entry.key}');
      }
      data[entry.key] = _convert(entry.value);
    }
    return data;
  }

  dynamic _convert(dynamic value) {
    if (value is String) {
      try {
        return ObjectId.parse(value);
      } on FormatException {
        return value;
      }
    }
    return value;
  }
}
