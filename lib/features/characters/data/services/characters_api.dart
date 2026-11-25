import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rickandmorty/features/characters/data/models/character.dart';
import 'package:rickandmorty/features/characters/data/models/episode.dart';
import 'package:rickandmorty/features/characters/data/models/location.dart';

class CharactersApiException implements Exception {
  final String message;
  final bool isConnectionError;

  CharactersApiException(this.message, {this.isConnectionError = false});

  @override
  String toString() => message;
}

class CharactersApi {
  static const _baseUrl = 'https://rickandmortyapi.com/api';
  final http.Client _client;

  CharactersApi(this._client);

  // GET /character?page=1&name=rick
  Future<({List<Character> characters, bool hasNext})> getCharacters({
    int page = 1,
    String? name,
  }) async {
    final uri = Uri.parse('$_baseUrl/character').replace(
      queryParameters: {
        'page': '$page',
        if (name != null && name.isNotEmpty) 'name': name,
      },
    );

    final response = await _get(uri);

    // 404 = ningún personaje coincide con el filtro.
    if (response.statusCode == 404) {
      return (characters: <Character>[], hasNext: false);
    }
    _checkOk(response, 'No pudimos cargar los personajes');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final info = body['info'] as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>;

    return (
      characters: results
          .map((json) => Character.fromJson(json as Map<String, dynamic>))
          .toList(),
      hasNext: info['next'] != null,
    );
  }

  // GET /character/{id}
  Future<Character> getCharacter(int id) async {
    final response = await _get(Uri.parse('$_baseUrl/character/$id'));
    _checkOk(response, 'No encontramos a este personaje');
    return Character.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  // GET /character/1,2,3
  Future<List<Character>> getCharactersByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final response = await _get(
      Uri.parse('$_baseUrl/character/${ids.join(',')}'),
    );
    _checkOk(response, 'No pudimos cargar los personajes');
    return _decodeList(response.body).map(Character.fromJson).toList();
  }

  // GET /episode/1,2,3
  Future<List<Episode>> getEpisodes(List<int> ids) async {
    if (ids.isEmpty) return [];
    final response = await _get(
      Uri.parse('$_baseUrl/episode/${ids.join(',')}'),
    );
    _checkOk(response, 'No pudimos cargar los episodios');
    return _decodeList(response.body).map(Episode.fromJson).toList();
  }

  // GET /location/{id}
  Future<Location> getLocation(int id) async {
    final response = await _get(Uri.parse('$_baseUrl/location/$id'));
    _checkOk(response, 'No pudimos cargar la ubicación');
    return Location.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      return await _client.get(uri);
    } on http.ClientException {
      throw CharactersApiException(
        'No hay conexión a internet',
        isConnectionError: true,
      );
    }
  }

  void _checkOk(http.Response response, String message) {
    if (response.statusCode != 200) {
      throw CharactersApiException('$message (${response.statusCode})');
    }
  }

  // Con un solo id la API devuelve un objeto en lugar de una lista.
  List<Map<String, dynamic>> _decodeList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) return decoded.cast<Map<String, dynamic>>();
    return [decoded as Map<String, dynamic>];
  }
}
