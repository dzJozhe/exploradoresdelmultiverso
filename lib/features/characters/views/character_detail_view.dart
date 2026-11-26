import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rickandmorty/core/providers.dart';
import 'package:rickandmorty/core/widgets/character_avatar.dart';
import 'package:rickandmorty/features/characters/data/models/character.dart';
import 'package:rickandmorty/features/characters/data/models/episode.dart';
import 'package:rickandmorty/features/characters/data/models/location.dart';
import 'package:rickandmorty/features/characters/ui/view_models/character_detail_view_model.dart';

const _accent = Color(0xFFA8E05F);
const _muted = Color(0xFFB4BCC8);
const _cardBg = Color(0xFF19202A);
const _cardBorder = Color(0xFF29313C);

class CharacterDetailView extends ConsumerStatefulWidget {
  final int? characterId;

  const CharacterDetailView({super.key, this.characterId});

  @override
  ConsumerState<CharacterDetailView> createState() =>
      _CharacterDetailViewState();
}

class _CharacterDetailViewState extends ConsumerState<CharacterDetailView> {
  int? _expandedEpisode = 0;

  void _goBack() {
    // Sin historial (p. ej. al recargar en web) vuelve a la lista.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.characterId;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0b132b), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _topBar(id),
                Expanded(
                  child: id == null
                      ? _message(
                          title: 'Personaje no encontrado',
                          message: 'Revisa el enlace e inténtalo de nuevo.',
                        )
                      : _content(id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(int id) {
    final state = ref.watch(characterDetailViewModelProvider(id));
    final viewModel = ref.read(characterDetailViewModelProvider(id).notifier);
    final character = state.character;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }

    if (state.error != null || character == null) {
      return _message(
        title: state.isConnectionError
            ? 'No hay conexión a internet'
            : 'Algo salió mal',
        message: state.error ?? 'No pudimos cargar el personaje.',
        onRetry: viewModel.loadCharacter,
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      children: [
        if (state.isFromCache) ...[
          _offlineBanner(state.isCacheComplete),
          const SizedBox(height: 20),
        ],
        _header(character),
        const SizedBox(height: 28),
        _sectionTitle('Ubicaciones'),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _locationCard(
                  'Origen',
                  character.origin.name,
                  state.origin,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _locationCard(
                  'Última ubicación',
                  character.location.name,
                  state.lastLocation,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _sectionTitle('Episodios en los que aparece'),
        const SizedBox(height: 14),
        if (state.episodes.isEmpty && state.isFromCache)
          const Text(
            'Los episodios de este personaje no se guardaron. '
            'Se descargarán cuando vuelvas a tener conexión.',
            style: TextStyle(color: _muted),
          ),
        for (int i = 0; i < state.episodes.length; i++)
          _episodeTile(i, state.episodes[i], state, viewModel),
      ],
    );
  }

  Widget _offlineBanner(bool isComplete) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B5A1F)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wifi_off, color: Color(0xFFF2C14E), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sin conexión',
                  style: TextStyle(
                    color: Color(0xFFF5D27A),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isComplete
                      ? 'Mostrando los datos que guardaste en este dispositivo.'
                      : 'Solo se guardaron los datos básicos de este personaje.',
                  style: const TextStyle(
                    color: Color(0xFFE8DDBF),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(int? id) {
    final state = id == null
        ? null
        : ref.watch(characterDetailViewModelProvider(id));
    final character = state?.character;
    // Lo leído de SQLite sin ubicaciones ni episodios no se vuelve a guardar.
    final detailToSave = state == null || !state.isCacheComplete
        ? null
        : state.detail;
    final isFavorite =
        character != null &&
        (ref.watch(savedViewModelProvider).value ?? const []).any(
          (c) => c.id == character.id,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _goBack,
          tooltip: 'Regresar',
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        IconButton(
          onPressed: character == null
              ? null
              : () => ref
                    .read(savedViewModelProvider.notifier)
                    .toggleFavorite(character, detail: detailToSave),
          tooltip: isFavorite ? 'Quitar de guardados' : 'Guardar',
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? _accent : _muted,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _header(Character character) {
    return Row(
      children: [
        CharacterAvatar(
          name: character.name,
          imageUrl: character.image,
          radius: 36,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                character.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(
                    _statusLabel(character.status),
                    dotColor: _statusColor(character.status),
                  ),
                  _chip(_speciesLabel(character.species)),
                  _chip(_genderLabel(character.gender)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, {Color? dotColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _locationCard(String label, String name, Location? location) {
    final details = location == null
        ? ''
        : [
            _locationTypeLabel(location.type),
            _dimensionLabel(location.dimension),
          ].where((part) => part.isNotEmpty).join(' · ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name == 'unknown' ? 'Desconocida' : name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(details, style: const TextStyle(color: _muted, fontSize: 14)),
          ],
          const Spacer(),
          if (location != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                // TODO: navegar a los residentes (location.residents).
              },
              child: const Text(
                'Ver residentes ›',
                style: TextStyle(color: _accent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _episodeTile(
    int index,
    Episode episode,
    CharacterDetailState state,
    CharacterDetailViewModel viewModel,
  ) {
    final expanded = _expandedEpisode == index;
    final radius = BorderRadius.circular(16);
    final others = state.episodeCharacters[episode.id];
    final loadingOthers = state.loadingEpisodes.contains(episode.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: radius,
        border: Border.all(color: _cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() => _expandedEpisode = expanded ? null : index);
                if (!expanded) viewModel.loadEpisodeCharacters(episode);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        episode.code,
                        style: const TextStyle(
                          color: Color(0xFF0E1217),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        episode.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: _muted,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: expanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, color: _cardBorder),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emitido el ${_airDateLabel(episode.airDate)}',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (loadingOthers || others == null)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _accent,
                                  ),
                                )
                              else if (others.isNotEmpty)
                                Row(
                                  children: [
                                    _stackedAvatars(others),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Otros personajes del episodio',
                                        style: TextStyle(color: _muted),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stackedAvatars(List<Character> characters) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < characters.length; i++)
          Align(
            widthFactor: i == characters.length - 1 ? 1 : 0.8,
            child: GestureDetector(
              onTap: () => context.push('/characters/${characters[i].id}'),
              child: Tooltip(
                message: characters[i].name,
                child: CharacterAvatar(
                  name: characters[i].name,
                  imageUrl: characters[i].image,
                  radius: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _message({
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            style: const TextStyle(color: _muted),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: const Color(0xFF0E1217),
              ),
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) => switch (status.toLowerCase()) {
    'alive' => _accent,
    'dead' => Colors.redAccent,
    _ => Colors.grey,
  };

  String _statusLabel(String status) => switch (status.toLowerCase()) {
    'alive' => 'Vivo',
    'dead' => 'Muerto',
    _ => 'Desconocido',
  };

  String _speciesLabel(String species) => switch (species.toLowerCase()) {
    'human' => 'Humano',
    'alien' => 'Alienígena',
    'humanoid' => 'Humanoide',
    'robot' => 'Robot',
    'animal' => 'Animal',
    'mythological creature' => 'Criatura mitológica',
    'disease' => 'Enfermedad',
    'poopybutthole' => 'Poopybutthole',
    'cronenberg' => 'Cronenberg',
    'unknown' => 'Especie desconocida',
    _ => species,
  };

  String _genderLabel(String gender) => switch (gender.toLowerCase()) {
    'male' => 'Masculino',
    'female' => 'Femenino',
    'genderless' => 'Sin género',
    _ => 'Género desconocido',
  };

  String _locationTypeLabel(String type) => switch (type.toLowerCase()) {
    'planet' => 'Planeta',
    'space station' => 'Estación espacial',
    'cluster' => 'Cúmulo',
    'microverse' => 'Microverso',
    'tv' => 'TV',
    'resort' => 'Resort',
    'fantasy town' => 'Pueblo de fantasía',
    'dream' => 'Sueño',
    'dimension' => 'Dimensión',
    'unknown' || '' => '',
    _ => type,
  };

  // "Dimension C-137" -> "Dimensión C-137", "unknown" -> "Dimensión desconocida"
  String _dimensionLabel(String dimension) {
    if (dimension.isEmpty) return '';
    if (dimension.toLowerCase() == 'unknown') return 'Dimensión desconocida';
    return dimension.replaceFirst('Dimension', 'Dimensión');
  }

  // "December 2, 2013" -> "2 de diciembre de 2013"
  String _airDateLabel(String airDate) {
    const months = {
      'January': 'enero',
      'February': 'febrero',
      'March': 'marzo',
      'April': 'abril',
      'May': 'mayo',
      'June': 'junio',
      'July': 'julio',
      'August': 'agosto',
      'September': 'septiembre',
      'October': 'octubre',
      'November': 'noviembre',
      'December': 'diciembre',
    };
    final match = RegExp(r'^(\w+) (\d+), (\d{4})$').firstMatch(airDate);
    final month = months[match?.group(1)];
    if (match == null || month == null) return airDate;
    return '${match.group(2)} de $month de ${match.group(3)}';
  }
}
