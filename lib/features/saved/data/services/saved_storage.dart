import 'dart:convert';

import 'package:rickandmorty/features/characters/data/models/character.dart';
import 'package:rickandmorty/features/characters/data/models/character_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

// Favoritos por número de teléfono (tabla "favorites").
class SavedLocalStorage {
  static const _table = 'favorites';
  final Database _db;

  SavedLocalStorage(this._db);

  Future<List<Character>> getFavorites(String phone) async {
    final rows = await _db.query(
      _table,
      columns: ['data'],
      where: 'phone = ?',
      whereArgs: [phone],
      orderBy: 'saved_at ASC',
    );

    final favorites = <Character>[];
    for (final row in rows) {
      try {
        favorites.add(
          Character.fromJson(
            jsonDecode(row['data'] as String) as Map<String, dynamic>,
          ),
        );
      } on FormatException {
        // registro inválido: se omite
      }
    }
    return favorites;
  }

  Future<void> addFavorite(
    String phone,
    Character character, {
    CharacterDetail? detail,
  }) async {
    await _db.insert(_table, {
      'phone': phone,
      'character_id': character.id,
      'data': jsonEncode(character.toJson()),
      'detail': detail == null ? null : jsonEncode(detail.toJson()),
      'saved_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Actualiza el detalle solo si el personaje sigue guardado por ese número.
  Future<void> saveDetail(String phone, CharacterDetail detail) async {
    await _db.update(
      _table,
      {
        'data': jsonEncode(detail.character.toJson()),
        'detail': jsonEncode(detail.toJson()),
      },
      where: 'phone = ? AND character_id = ?',
      whereArgs: [phone, detail.character.id],
    );
  }

  // Detalle guardado de un favorito. Si solo se guardó el personaje
  // (sin ubicaciones ni episodios), [isComplete] es false.
  Future<({CharacterDetail detail, bool isComplete})?> getDetail(
    String phone,
    int characterId,
  ) async {
    final rows = await _db.query(
      _table,
      columns: ['data', 'detail'],
      where: 'phone = ? AND character_id = ?',
      whereArgs: [phone, characterId],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    try {
      final detailJson = row['detail'] as String?;
      if (detailJson != null) {
        return (
          detail: CharacterDetail.fromJson(
            jsonDecode(detailJson) as Map<String, dynamic>,
          ),
          isComplete: true,
        );
      }
      final character = Character.fromJson(
        jsonDecode(row['data'] as String) as Map<String, dynamic>,
      );
      return (detail: CharacterDetail(character: character), isComplete: false);
    } on FormatException {
      return null;
    }
  }

  Future<void> removeFavorite(String phone, int characterId) async {
    await _db.delete(
      _table,
      where: 'phone = ? AND character_id = ?',
      whereArgs: [phone, characterId],
    );
  }

  Future<void> migrateFromSharedPreferences(SharedPreferences prefs) async {
    const oldPrefix = 'favorites_';
    final oldKeys = prefs.getKeys().where((k) => k.startsWith(oldPrefix));

    for (final key in oldKeys.toList()) {
      final phone = key.substring(oldPrefix.length);
      final saved = prefs.getStringList(key) ?? [];
      var order = 0;
      final batch = _db.batch();
      for (final json in saved) {
        try {
          final character = Character.fromJson(
            jsonDecode(json) as Map<String, dynamic>,
          );
          batch.insert(_table, {
            'phone': phone,
            'character_id': character.id,
            'data': jsonEncode(character.toJson()),
            'saved_at': order++,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        } on FormatException {
          // registro inválido: se omite
        }
      }
      await batch.commit(noResult: true);
      await prefs.remove(key);
    }
  }
}
