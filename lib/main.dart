import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rickandmorty/app/app.dart';
import 'package:rickandmorty/core/database/app_database.dart';
import 'package:rickandmorty/core/providers.dart';
import 'package:rickandmorty/features/saved/data/services/saved_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final db = await AppDatabase.open();
  await SavedLocalStorage(db).migrateFromSharedPreferences(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: const App(),
    ),
  );
}
