class Character {
  final int id;
  final String name;
  final String status; // Alive / Dead / unknown
  final String species;
  final String type;
  final String gender; // Female / Male / Genderless / unknown
  final CharacterPlace origin;
  final CharacterPlace location;
  final String image;
  final List<String> episodes; // URLs de los episodios

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
    required this.episodes,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      species: json['species'] as String? ?? '',
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String? ?? 'unknown',
      origin: CharacterPlace.fromJson(json['origin'] as Map<String, dynamic>?),
      location: CharacterPlace.fromJson(
        json['location'] as Map<String, dynamic>?,
      ),
      image: json['image'] as String? ?? '',
      episodes: (json['episode'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status,
    'species': species,
    'type': type,
    'gender': gender,
    'origin': origin.toJson(),
    'location': location.toJson(),
    'image': image,
    'episode': episodes,
  };
}

class CharacterPlace {
  final String name;
  final String url;

  CharacterPlace({required this.name, required this.url});

  factory CharacterPlace.fromJson(Map<String, dynamic>? json) {
    return CharacterPlace(
      name: json?['name'] as String? ?? 'unknown',
      url: json?['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'url': url};
}
