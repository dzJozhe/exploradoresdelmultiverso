import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStorage {
  static const _sessionKey = 'active_session';
  final SharedPreferences _storage;

  AuthLocalStorage(this._storage);

  String? getSession() => _storage.getString(_sessionKey);

  Future<void> saveSession(String phone) async {
    await _storage.setString(_sessionKey, phone);
  }

  Future<bool> clearSession() => _storage.remove(_sessionKey);
}
