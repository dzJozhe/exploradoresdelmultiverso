class Episode {
  final int id;
  final String name;
  final String airDate; // "December 2, 2013"
  final String code; // "S01E01"
  final List<String> characters; // URLs de los personajes

  Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.code,
    required this.characters,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      airDate: json['air_date'] as String? ?? '',
      code: json['episode'] as String? ?? '',
      characters: (json['characters'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}
