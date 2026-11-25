import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rickandmorty/core/providers.dart';
import 'package:rickandmorty/features/characters/data/models/character.dart';
import 'package:rickandmorty/features/characters/data/models/episode.dart';
import 'package:rickandmorty/features/characters/data/models/location.dart';
import 'package:rickandmorty/features/characters/data/services/characters_api.dart';

class CharacterDetailState {
  final Character? character;
  final Location? origin; // null si es "unknown"
  final Location? lastLocation;
  final List<Episode> episodes;
  // episodeId -> otros personajes del episodio
  final Map<int, List<Character>> episodeCharacters;
  final Set<int> loadingEpisodes;
  final bool isLoading;
  final String? error;
  final bool isConnectionError;

  const CharacterDetailState({
    this.character,
    this.origin,
    this.lastLocation,
    this.episodes = const [],
    this.episodeCharacters = const {},
    this.loadingEpisodes = const {},
    this.isLoading = false,
    this.error,
    this.isConnectionError = false,
  });

  CharacterDetailState copyWith({
    Map<int, List<Character>>? episodeCharacters,
    Set<int>? loadingEpisodes,
  }) {
    return CharacterDetailState(
      character: character,
      origin: origin,
      lastLocation: lastLocation,
      episodes: episodes,
      episodeCharacters: episodeCharacters ?? this.episodeCharacters,
      loadingEpisodes: loadingEpisodes ?? this.loadingEpisodes,
      isLoading: isLoading,
      error: error,
      isConnectionError: isConnectionError,
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
    final repository = ref.read(charactersRepositoryProvider);

    try {
      final character = await repository.getCharacter(characterId);

      final episodeIds = character.episodes
          .map(idFromUrl)
          .whereType<int>()
          .toList();
      final (origin, lastLocation, episodes) = await (
        repository.getLocationByUrl(character.origin.url),
        repository.getLocationByUrl(character.location.url),
        repository.getEpisodes(episodeIds),
      ).wait;

      if (!ref.mounted) return;

      state = CharacterDetailState(
        character: character,
        origin: origin,
        lastLocation: lastLocation,
        episodes: episodes,
      );

      if (episodes.isNotEmpty) loadEpisodeCharacters(episodes.first);
    } on CharactersApiException catch (e) {
      if (!ref.mounted) return;
      state = CharacterDetailState(
        error: e.message,
        isConnectionError: e.isConnectionError,
      );
    } on ParallelWaitError<dynamic, dynamic> catch (e) {
      if (!ref.mounted) return;
      final apiError = [
        e.errors.$1,
        e.errors.$2,
        e.errors.$3,
      ].whereType<AsyncError>().map((err) => err.error).firstOrNull;
      state = CharacterDetailState(
        error: apiError is CharactersApiException
            ? apiError.message
            : 'No pudimos cargar el personaje',
        isConnectionError:
            apiError is CharactersApiException && apiError.isConnectionError,
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
