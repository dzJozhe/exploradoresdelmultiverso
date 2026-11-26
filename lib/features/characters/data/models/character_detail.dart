import 'package:rickandmorty/features/characters/data/models/character.dart';
import 'package:rickandmorty/features/characters/data/models/episode.dart';
import 'package:rickandmorty/features/characters/data/models/location.dart';

/// Personaje con sus ubicaciones y episodios. Es lo que se guarda en SQLite
/// para consultar el detalle de un favorito sin conexión.
class CharacterDetail {
  final Character character;
  final Location? origin; // null si es "unknown"
  final Location? lastLocation;
  final List<Episode> episodes;

  CharacterDetail({
    required this.character,
    this.origin,
    this.lastLocation,
    this.episodes = const [],
  });

  factory CharacterDetail.fromJson(Map<String, dynamic> json) {
    Location? location(Object? value) =>
        value == null ? null : Location.fromJson(value as Map<String, dynamic>);

    return CharacterDetail(
      character: Character.fromJson(json['character'] as Map<String, dynamic>),
      origin: location(json['origin']),
      lastLocation: location(json['lastLocation']),
      episodes: (json['episodes'] as List<dynamic>? ?? [])
          .map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'character': character.toJson(),
    'origin': origin?.toJson(),
    'lastLocation': lastLocation?.toJson(),
    'episodes': episodes.map((e) => e.toJson()).toList(),
  };
}
