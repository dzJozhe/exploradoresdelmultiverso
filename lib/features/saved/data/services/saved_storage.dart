import 'dart:convert';

import 'package:rickandmorty/features/characters/data/models/character.dart';
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

  Future<void> addFavorite(String phone, Character character) async {
    await _db.insert(_table, {
      'phone': phone,
      'character_id': character.id,
      'data': jsonEncode(character.toJson()),
      'saved_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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
