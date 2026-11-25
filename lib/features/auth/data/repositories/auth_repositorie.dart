import 'dart:math';

import 'package:rickandmorty/features/auth/data/services/auth_storage.dart';

class AuthRepositorie {
  final AuthLocalStorage _storage;

  AuthRepositorie(this._storage);

  Future<String?> getAccessCode(String? phone) async {
    return phone == null || phone == ''
        ? null
        : (Random().nextInt(900000) + 100000).toString();
  }

  String? currentSession() => _storage.getSession();

  Future<void> saveSession(String phone) => _storage.saveSession(phone);

  Future<void> logout() => _storage.clearSession();
}
