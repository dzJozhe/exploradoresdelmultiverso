import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rickandmorty/core/providers.dart';
import 'package:rickandmorty/core/widgets/app_bottom_nav_bar.dart';
import 'package:rickandmorty/core/widgets/character_avatar.dart';
import 'package:rickandmorty/core/widgets/session_header.dart';

class CharactersView extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.go('/saved');
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentGeometry.topCenter,
            end: AlignmentGeometry.bottomCenter,
            colors: [Color(0xFF0b132b), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 8),
                child: const SessionHeader(title: 'Personajes'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: const _SearchField(),
              ),
              const SizedBox(height: 20),
              Expanded(child: _charactersList(context, ref)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _charactersList(BuildContext context, WidgetRef ref) {
    final state = ref.watch(charactersViewModelProvider);
    final favorites = ref.watch(savedViewModelProvider).value ?? const [];
    final viewModel = ref.read(charactersViewModelProvider.notifier);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFA8E05F)),
      );
    }

    if (state.error != null && state.characters.isEmpty) {
      return _errorMessage(
        title: state.isConnectionError
            ? 'No hay conexión a internet'
            : 'Algo salió mal',
        message: state.isConnectionError
            ? 'No pudimos cargar los personajes. Revisa tu señal o abre tus '
                  'guardados, que funcionan sin conexión.'
            : state.error!,
        onRetry: viewModel.loadCharacters,
      );
    }

    if (state.characters.isEmpty) {
      if (state.query.isNotEmpty) {
        return _noResults(state.query, viewModel.clearSearch);
      }
      return const Center(
        child: Text(
          'No hay personajes para mostrar',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 300) {
          viewModel.loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        // +1 para el pie de la lista
        itemCount: state.characters.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.characters.length) {
            return _listFooter(
              hasError: state.error != null,
              onRetry: viewModel.loadMore,
            );
          }
          final character = state.characters[index];
          return Center(
            child: cardCharacter(
              context,
              name: character.name,
              status: character.status,
              species: character.species,
              imageUrl: character.image,

              isFavorite: favorites.any((c) => c.id == character.id),
              onFavoriteTap: () => ref
                  .read(savedViewModelProvider.notifier)
                  .toggleFavorite(character),
              onTap: () => context.push('/characters/${character.id}'),
            ),
          );
        },
      ),
    );
  }

  Widget _noResults(String query, VoidCallback onClear) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, color: Color(0xFF86C5E8), size: 40),
          const SizedBox(height: 12),
          Text(
            'No encontramos a “$query”',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ningún personaje coincide con tu búsqueda. Revisa la ortografía '
            'o prueba con otro nombre.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFB4BCC8)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF29313C)),
            ),
            onPressed: onClear,
            child: const Text('Limpiar búsqueda'),
          ),
        ],
      ),
    );
  }

  Widget _listFooter({required bool hasError, required VoidCallback onRetry}) {
    if (hasError) {
      return Center(
        child: TextButton(
          onPressed: onRetry,
          child: const Text(
            'No se pudieron cargar más. Reintentar',
            style: TextStyle(color: Color(0xFFA8E05F)),
          ),
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFA8E05F),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Cargando más personajes…',
            style: TextStyle(color: Color(0xFFB4BCC8)),
          ),
        ],
      ),
    );
  }

  Widget _errorMessage({
    required String title,
    required String message,
    required VoidCallback onRetry,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Color(0xFFB4BCC8), size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB4BCC8)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA8E05F),
              foregroundColor: const Color(0xFF0E1217),
            ),
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget cardCharacter(
    BuildContext context, {
    String name = 'Rick Sanchez',
    String status = 'Alive', // Alive / Dead / unknown
    String species = 'Human',
    String? imageUrl,
    bool isFavorite = false,
    VoidCallback? onTap,
    VoidCallback? onFavoriteTap,
  }) {
    const accent = Color(0xFFA8E05F);
    final radius = BorderRadius.circular(16);

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF19202A),
        borderRadius: radius,
        border: Border.all(color: const Color(0xFF29313C), width: 1),
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
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _statusColor(status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${_statusLabel(status)} · ${_speciesLabel(species)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFB4BCC8),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFavoriteTap,
                  tooltip: isFavorite ? 'Quitar de guardados' : 'Guardar',
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? accent : const Color(0xFFB4BCC8),
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return const Color(0xFFA8E05F);
      case 'dead':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return 'Vivo';
      case 'dead':
        return 'Muerto';
      default:
        return 'Desconocido';
    }
  }

  String _speciesLabel(String species) {
    switch (species.toLowerCase()) {
      case 'human':
        return 'Humano';
      case 'alien':
        return 'Alienígena';
      case 'humanoid':
        return 'Humanoide';
      case 'robot':
        return 'Robot';
      default:
        return species;
    }
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final _controller = TextEditingController(
    text: ref.read(charactersViewModelProvider).query,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Vacía el campo cuando la búsqueda se limpia desde fuera.
    ref.listen(charactersViewModelProvider.select((s) => s.query), (_, query) {
      if (query.isEmpty && _controller.text.isNotEmpty) _controller.clear();
    });

    return TextFormField(
      controller: _controller,
      onChanged: (text) {
        ref.read(charactersViewModelProvider.notifier).search(text);
        setState(() {});
      },
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar búsqueda',
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  _controller.clear();
                  ref.read(charactersViewModelProvider.notifier).clearSearch();
                  setState(() {});
                },
              ),
        fillColor: const Color.fromARGB(103, 6, 6, 6),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        hint: const Text(
          'Buscar por nombre',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
