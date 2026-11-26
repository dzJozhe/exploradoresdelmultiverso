class Location {
  final int id;
  final String name;
  final String type; // "Planet", "Space station", ...
  final String dimension; // "Dimension C-137", "unknown", ...
  final List<String> residents; // URLs de los personajes

  Location({
    required this.id,
    required this.name,
    required this.type,
    required this.dimension,
    required this.residents,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      dimension: json['dimension'] as String? ?? '',
      residents: (json['residents'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'dimension': dimension,
    'residents': residents,
  };
}

// Id al final de una URL de la API; null si la URL está vacía.
int? idFromUrl(String url) => int.tryParse(url.split('/').last);
