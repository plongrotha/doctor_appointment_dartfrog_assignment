import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:doctor_appointment_api/database/create_collections.dart';
import 'package:doctor_appointment_api/database/mongo_database.dart';

Future<void> init(InternetAddress ip, int port) async {
  // called to create the collections if they don't exist
  await createCollections();
  await MongoDatabase.connect();
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serve(handler, ip, port);
}
