import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// En web requiere web/sqlite3.wasm y web/sqflite_sw.js
// (se generan con: dart run sqflite_common_ffi_web:setup).
class AppDatabase {
  static const _name = 'rickandmorty.db';
  static const _version = 2;

  static Future<Database> open({DatabaseFactory? factory, String? path}) async {
    final dbFactory =
        factory ?? (kIsWeb ? databaseFactoryFfiWeb : databaseFactory);
    final dbPath =
        path ?? (kIsWeb ? _name : p.join(await getDatabasesPath(), _name));

    final options = OpenDatabaseOptions(
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    try {
      return await dbFactory.openDatabase(dbPath, options: options);
    } on DatabaseException catch (e) {
      // Si el SharedWorker no está disponible, se usa SQLite sin worker.
      if (!kIsWeb || factory != null) rethrow;
      debugPrint('SQLite: worker no disponible, se usa modo sin worker ($e)');
      return databaseFactoryFfiWebNoWebWorker.openDatabase(
        dbPath,
        options: options,
      );
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        phone TEXT NOT NULL,
        character_id INTEGER NOT NULL,
        data TEXT NOT NULL, -- personaje en JSON
        detail TEXT, -- CharacterDetail en JSON (ubicaciones y episodios)
        saved_at INTEGER NOT NULL,
        PRIMARY KEY (phone, character_id)
      )
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE favorites ADD COLUMN detail TEXT');
    }
  }
}
