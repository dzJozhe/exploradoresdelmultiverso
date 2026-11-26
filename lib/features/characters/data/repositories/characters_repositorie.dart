import 'dart:async';

import 'package:rickandmorty/features/characters/data/models/character.dart';
import 'package:rickandmorty/features/characters/data/models/character_detail.dart';
import 'package:rickandmorty/features/characters/data/models/episode.dart';
import 'package:rickandmorty/features/characters/data/models/location.dart';
import 'package:rickandmorty/features/characters/data/services/characters_api.dart';

class CharactersRepositorie {
  final CharactersApi _api;

  CharactersRepositorie(this._api);

  Future<({List<Character> characters, bool hasNext})> getCharacters({
    int page = 1,
    String? name,
  }) => _api.getCharacters(page: page, name: name);

  Future<Character> getCharacter(int id) => _api.getCharacter(id);

  Future<List<Character>> getCharactersByIds(List<int> ids) =>
      _api.getCharactersByIds(ids);

  Future<List<Episode>> getEpisodes(List<int> ids) => _api.getEpisodes(ids);

  Future<Location?> getLocationByUrl(String url) async {
    final id = idFromUrl(url);
    return id == null ? null : _api.getLocation(id);
  }

  // Personaje + origen + última ubicación + episodios.
  Future<CharacterDetail> getCharacterDetail(int id) async {
    final character = await getCharacter(id);
    final episodeIds = character.episodes
        .map(idFromUrl)
        .whereType<int>()
        .toList();

    try {
      final (origin, lastLocation, episodes) = await (
        getLocationByUrl(character.origin.url),
        getLocationByUrl(character.location.url),
        getEpisodes(episodeIds),
      ).wait;
      return CharacterDetail(
        character: character,
        origin: origin,
        lastLocation: lastLocation,
        episodes: episodes,
      );
    } on ParallelWaitError<dynamic, dynamic> catch (e) {
      final error = [
        e.errors.$1,
        e.errors.$2,
        e.errors.$3,
      ].whereType<AsyncError>().map((err) => err.error).firstOrNull;
      if (error is CharactersApiException) throw error;
      throw CharactersApiException('No pudimos cargar el personaje');
    }
  }
}
