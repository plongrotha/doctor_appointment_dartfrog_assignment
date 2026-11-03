// ignore_for_file: public_member_api_docs

import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static Db? _db;

  static Db get database {
    final db = _db;

    if (db == null || !db.isConnected) {
      throw StateError('MongoDB has not been initialized.');
    }

    return db;
  }

  static Future<Db> connect() async {
    if (_db != null && _db!.isConnected) {
      return _db!;
    }

    final db = Db(
      'mongodb://admin:password123@localhost:27017/doctor_appointmentdb?authSource=admin',
    );

    await db.open();

    _db = db;
    // ignore: avoid_print
    print('Connected to MongoDB');

    return db;
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
