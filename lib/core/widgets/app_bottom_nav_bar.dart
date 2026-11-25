import 'package:flutter/material.dart';

/// Barra inferior compartida. [currentIndex]: 0 = Personajes, 1 = Guardados.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _background = Color(0xFF121920);
  static const _border = Color(0xFF232B35);
  static const _active = Color(0xFFA8E05F);
  static const _inactive = Color(0xFFA9B3BF);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _background,
        border: Border(top: BorderSide(color: _border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _item(index: 0, icon: Icons.people_outline, label: 'Personajes'),
              _item(index: 1, icon: Icons.bookmark_border, label: 'Guardados'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = index == currentIndex;
    final color = selected ? _active : _inactive;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: selected ? null : () => onTap(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
