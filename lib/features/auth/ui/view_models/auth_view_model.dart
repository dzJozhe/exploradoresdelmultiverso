import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rickandmorty/core/providers.dart';

class AuthViewModel extends Notifier<String?> {
  @override
  String? build() {
    return ref.read(authRepositoryProvider).currentSession();
  }

  Future<Map<String, String?>> enviarTelefono(String phone) async {
    final code = await ref.read(authRepositoryProvider).getAccessCode(phone);

    if (code != null) {
      return {'code': code, 'phone': phone};
    }

    return {'code': null, 'phone': null};
  }

  Future<String> resendCode(String phone) async {
    final code = await ref.read(authRepositoryProvider).getAccessCode(phone);
    if (code != null) {
      return code;
    }
    return '';
  }

  Future<bool> verifyCode(
    String originalCode,
    String codeToVerify,
    String phone,
  ) async {
    if (originalCode == codeToVerify) {
      ref.read(authRepositoryProvider).saveSession(phone);
      state = phone;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = null;
  }
}
