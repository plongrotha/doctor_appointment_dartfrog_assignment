// ignore_for_file: public_member_api_docs, avoid_print

import 'package:doctor_appointment_api/database/mongo_database.dart';

Future<void> createCollections() async {
  final db = await MongoDatabase.connect();

  final names = await db.getCollectionNames();

  for (final name in [
    'users',
    'appointments',
    'reviews',
    'doctors',
    'specialties',
    'doctor_schedules',
    'notifications',
    'refresh_tokens',
    'password_reset_tokens',
  ]) {
    if (!names.contains(name)) {
      await db.createCollection(name);
      print('$name collection created');
    } else {
      print('$name collection already exists');
    }
  }
}
