import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rickandmorty/core/providers.dart';
import 'package:rickandmorty/features/characters/data/models/character.dart';
import 'package:rickandmorty/features/characters/data/models/character_detail.dart';
import 'package:rickandmorty/features/characters/data/models/episode.dart';
import 'package:rickandmorty/features/characters/data/models/location.dart';
import 'package:rickandmorty/features/characters/data/services/characters_api.dart';

class CharacterDetailState {
  final CharacterDetail? detail;
  // episodeId -> otros personajes del episodio
  final Map<int, List<Character>> episodeCharacters;
  final Set<int> loadingEpisodes;
  final bool isLoading;
  final String? error;
  final bool isConnectionError;
  // true: datos leídos de SQLite porque la API no respondió.
  final bool isFromCache;
  // false: del favorito solo se guardó el personaje, sin ubicaciones ni episodios.
  final bool isCacheComplete;

  const CharacterDetailState({
    this.detail,
    this.episodeCharacters = const {},
    this.loadingEpisodes = const {},
    this.isLoading = false,
    this.error,
    this.isConnectionError = false,
    this.isFromCache = false,
    this.isCacheComplete = true,
  });

  Character? get character => detail?.character;
  Location? get origin => detail?.origin;
  Location? get lastLocation => detail?.lastLocation;
  List<Episode> get episodes => detail?.episodes ?? const [];

  CharacterDetailState copyWith({
    Map<int, List<Character>>? episodeCharacters,
    Set<int>? loadingEpisodes,
  }) {
    return CharacterDetailState(
      detail: detail,
      episodeCharacters: episodeCharacters ?? this.episodeCharacters,
      loadingEpisodes: loadingEpisodes ?? this.loadingEpisodes,
      isLoading: isLoading,
      error: error,
      isConnectionError: isConnectionError,
      isFromCache: isFromCache,
      isCacheComplete: isCacheComplete,
    );
  }
}

class CharacterDetailViewModel extends Notifier<CharacterDetailState> {
  final int characterId;

  CharacterDetailViewModel(this.characterId);

  @override
  CharacterDetailState build() {
    Future.microtask(loadCharacter);
    return const CharacterDetailState(isLoading: true);
  }

  Future<void> loadCharacter() async {
    state = const CharacterDetailState(isLoading: true);
    final network = ref.read(networkStatusProvider.notifier);

    try {
      final detail = await ref
          .read(charactersRepositoryProvider)
          .getCharacterDetail(characterId);
      network.markOnline();
      if (!ref.mounted) return;

      state = CharacterDetailState(detail: detail);
      // Si es favorito, se actualiza lo guardado para consultarlo sin conexión.
      await ref.read(savedViewModelProvider.notifier).saveDetail(detail);

      if (!ref.mounted) return;
      if (detail.episodes.isNotEmpty) {
        loadEpisodeCharacters(detail.episodes.first);
      }
    } on CharactersApiException catch (e) {
      if (e.isConnectionError) network.markOffline();
      final phone = ref.read(authViewModelProvider);
      final cached = phone == null
          ? null
          : await ref
                .read(savedRepositoryProvider)
                .getDetail(phone, characterId);
      if (!ref.mounted) return;

      state = cached != null
          ? CharacterDetailState(
              detail: cached.detail,
              isConnectionError: e.isConnectionError,
              isFromCache: true,
              isCacheComplete: cached.isComplete,
            )
          : CharacterDetailState(
              error: e.message,
              isConnectionError: e.isConnectionError,
            );
    }
  }

  // Hasta 4 personajes del episodio, sin incluir al actual.
  Future<void> loadEpisodeCharacters(Episode episode) async {
    if (state.episodeCharacters.containsKey(episode.id) ||
        state.loadingEpisodes.contains(episode.id)) {
      return;
    }

    final ids = episode.characters
        .map(idFromUrl)
        .whereType<int>()
        .where((id) => id != characterId)
        .take(4)
        .toList();

    state = state.copyWith(
      loadingEpisodes: {...state.loadingEpisodes, episode.id},
    );

    List<Character> others;
    try {
      others = await ref
          .read(charactersRepositoryProvider)
          .getCharactersByIds(ids);
    } on CharactersApiException {
      others = [];
    }

    if (!ref.mounted) return;
    state = state.copyWith(
      episodeCharacters: {...state.episodeCharacters, episode.id: others},
      loadingEpisodes: {...state.loadingEpisodes}..remove(episode.id),
    );
  }
}
