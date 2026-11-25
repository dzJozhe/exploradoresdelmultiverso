import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rickandmorty/core/providers.dart';

/// Encabezado con título, número enmascarado y botón de cerrar sesión.
class SessionHeader extends ConsumerWidget {
  final String title;

  const SessionHeader({super.key, required this.title});

  static const _accent = Color(0xFFA8E05F);
  static const _muted = Color(0xFFB4BCC8);
  static const _chipBg = Color(0xFF19202A);
  static const _chipBorder = Color(0xFF29313C);

  // "7771234567" -> "••4567"
  static String maskPhone(String phone) {
    if (phone.length <= 4) return phone;
    return '••${phone.substring(phone.length - 4)}';
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _chipBg,
        title: const Text(
          '¿Cerrar sesión?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tus guardados se quedan en este dispositivo y volverás a verlos '
          'al entrar con el mismo número.',
          style: TextStyle(color: _muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: _accent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await ref.read(authViewModelProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phone = ref.watch(authViewModelProvider) ?? '';

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _chipBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _chipBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_outlined, color: _accent, size: 16),
              const SizedBox(width: 8),
              Text(
                maskPhone(phone),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () => _logout(context, ref),
          tooltip: 'Cerrar sesión',
          icon: const Icon(Icons.logout, color: _muted),
        ),
      ],
    );
  }
}
