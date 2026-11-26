import 'package:flutter_riverpod/flutter_riverpod.dart';

/// true cuando la última petición a la API falló por falta de conexión.
class NetworkStatus extends Notifier<bool> {
  @override
  bool build() => false;

  void markOnline() {
    if (state) state = false;
  }

  void markOffline() {
    if (!state) state = true;
  }
}
