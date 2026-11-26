import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rickandmorty/core/providers.dart';
import 'package:rickandmorty/core/widgets/app_bottom_nav_bar.dart';
import 'package:rickandmorty/core/widgets/character_avatar.dart';
import 'package:rickandmorty/core/widgets/session_header.dart';

class SavedView extends ConsumerWidget {
  const SavedView({super.key});

  static const _accent = Color(0xFFA8E05F);
  static const _muted = Color(0xFFB4BCC8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(networkStatusProvider);
    final savedAsync = ref.watch(savedViewModelProvider);
    final saved = savedAsync.value ?? const [];

    return Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/characters');
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0b132b), Colors.black],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              const SessionHeader(title: 'Guardados'),
              const SizedBox(height: 20),
              if (isOffline) ...[_offlineBanner(), const SizedBox(height: 20)],
              if (savedAsync.isLoading && saved.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: _accent),
                  ),
                )
              else if (saved.isEmpty)
                _emptyState()
              else
                for (final character in saved)
                  _savedCard(
                    name: character.name,
                    imageUrl: character.image,
                    onTap: () => context.push('/characters/${character.id}'),
                    onRemove: () => ref
                        .read(savedViewModelProvider.notifier)
                        .toggleFavorite(character),
                  ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Solo ves los guardados de tu número. Al volver a abrir '
                  'la app, continúas donde te quedaste.',
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _offlineBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B5A1F)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Icon(Icons.wifi_off, color: Color(0xFFF2C14E), size: 22),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sin conexión',
                  style: TextStyle(
                    color: Color(0xFFF5D27A),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Mostrando los datos que guardaste en este dispositivo.',
                  style: TextStyle(color: Color(0xFFE8DDBF), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _savedCard({
    required String name,
    String? imageUrl,
    VoidCallback? onTap,
    VoidCallback? onRemove,
  }) {
    final radius = BorderRadius.circular(16);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF19202A),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFF29313C)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
            child: Row(
              children: [
                CharacterAvatar(name: name, imageUrl: imageUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(Icons.check, color: _accent, size: 14),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Guardado en este dispositivo',
                              style: TextStyle(color: _muted, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Quitar de guardados',
                  icon: const Icon(Icons.favorite, color: _accent, size: 26),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.bookmark_border, color: _muted, size: 40),
          SizedBox(height: 12),
          Text(
            'Aún no tienes guardados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Toca el corazón de un personaje para guardarlo aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted),
          ),
        ],
      ),
    );
  }
}
