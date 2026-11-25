import 'package:rickandmorty/features/characters/data/models/character.dart';
import 'package:rickandmorty/features/saved/data/services/saved_storage.dart';

class SavedRepositorie {
  final SavedLocalStorage _storage;

  SavedRepositorie(this._storage);

  Future<List<Character>> getFavorites(String phone) =>
      _storage.getFavorites(phone);

  Future<void> addFavorite(String phone, Character character) =>
      _storage.addFavorite(phone, character);

  Future<void> removeFavorite(String phone, int characterId) =>
      _storage.removeFavorite(phone, characterId);
}
