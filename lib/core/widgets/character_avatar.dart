import 'package:flutter/material.dart';

/// Avatar con la imagen del personaje. Mientras carga, si falla o si no hay
/// imagen, muestra las iniciales del nombre.
class CharacterAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;

  const CharacterAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 26,
  });

  static const _palette = [
    Color(0xFFA8E05F),
    Color(0xFFF2C14E),
    Color(0xFF86C5E8),
    Color(0xFFE8A0BF),
    Color(0xFFC3AEE0),
  ];

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _initialsAvatar();

    final size = radius * 2;
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _initialsAvatar(),
        errorBuilder: (context, error, stackTrace) => _initialsAvatar(),
      ),
    );
  }

  Widget _initialsAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _color(name),
      child: Text(
        _initials(name),
        style: TextStyle(
          color: const Color(0xFF0E1217),
          fontSize: radius * 0.62,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  static Color _color(String name) {
    final hash = name.codeUnits.fold<int>(0, (a, c) => a + c);
    return _palette[hash % _palette.length];
  }
}
