import 'package:rickandmorty/features/characters/data/models/character.dart';
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
}
