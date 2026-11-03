// ignore_for_file: public_member_api_docs

import 'package:bcrypt/bcrypt.dart';

class PasswordBcrypt {
  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  static bool verifyPassword({
    required String password,
    required String hashedPassword,
  }) {
    return BCrypt.checkpw(password, hashedPassword);
  }
}
