import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:rickandmorty/features/auth/data/repositories/auth_repositorie.dart';
import 'package:rickandmorty/features/auth/data/services/auth_storage.dart';
import 'package:rickandmorty/features/auth/ui/view_models/auth_view_model.dart';
import 'package:rickandmorty/features/characters/data/models/character.dart';
import 'package:rickandmorty/features/characters/data/repositories/characters_repositorie.dart';
import 'package:rickandmorty/features/characters/data/services/characters_api.dart';
import 'package:rickandmorty/features/characters/ui/view_models/character_detail_view_model.dart';
import 'package:rickandmorty/features/characters/ui/view_models/characters_view_model.dart';
import 'package:rickandmorty/features/saved/data/repositories/saved_repositorie.dart';
import 'package:rickandmorty/features/saved/data/services/saved_storage.dart';
import 'package:rickandmorty/features/saved/ui/view_models/saved_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

//PROVIDER DEL AuthRepositorie
final authRepositoryProvider = Provider<AuthRepositorie>((ref) {
  return AuthRepositorie(ref.watch(authStorageProvider));
});

//PROVIDER DEL VIEW MODEL AUTH
final authViewModelProvider = NotifierProvider<AuthViewModel, String?>(
  AuthViewModel.new,
);
//PROVIDERS PARA ALMACENAMIENTO LOCAL EN STORAGE
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

final authStorageProvider = Provider<AuthLocalStorage>(
  (ref) => AuthLocalStorage(ref.watch(sharedPreferencesProvider)),
);

//PROVIDERS DEL FEATURE DE PERSONAJES
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final charactersApiProvider = Provider<CharactersApi>(
  (ref) => CharactersApi(ref.watch(httpClientProvider)),
);

//PROVIDER DEL CharactersRepositorie
final charactersRepositoryProvider = Provider<CharactersRepositorie>((ref) {
  return CharactersRepositorie(ref.watch(charactersApiProvider));
});

//PROVIDER DEL VIEW MODEL DE PERSONAJES
final charactersViewModelProvider =
    NotifierProvider<CharactersViewModel, CharactersState>(
      CharactersViewModel.new,
    );

//PROVIDER DEL VIEW MODEL DEL DETALLE
final characterDetailViewModelProvider = NotifierProvider.autoDispose
    .family<CharacterDetailViewModel, CharacterDetailState, int>(
      CharacterDetailViewModel.new,
    );

//PROVIDERS DEL FEATURE DE GUARDADOS
final databaseProvider = Provider<Database>(
  (ref) => throw UnimplementedError(),
);

final savedStorageProvider = Provider<SavedLocalStorage>(
  (ref) => SavedLocalStorage(ref.watch(databaseProvider)),
);

//PROVIDER DEL SavedRepositorie
final savedRepositoryProvider = Provider<SavedRepositorie>((ref) {
  return SavedRepositorie(ref.watch(savedStorageProvider));
});

//PROVIDER DEL VIEW MODEL DE GUARDADOS
final savedViewModelProvider =
    AsyncNotifierProvider<SavedViewModel, List<Character>>(SavedViewModel.new);
