import 'package:rickandmorty/features/characters/data/models/character.dart';
import 'package:rickandmorty/features/characters/data/models/character_detail.dart';
import 'package:rickandmorty/features/saved/data/services/saved_storage.dart';

class SavedRepositorie {
  final SavedLocalStorage _storage;

  SavedRepositorie(this._storage);

  Future<List<Character>> getFavorites(String phone) =>
      _storage.getFavorites(phone);

  Future<void> addFavorite(
    String phone,
    Character character, {
    CharacterDetail? detail,
  }) => _storage.addFavorite(phone, character, detail: detail);

  Future<void> removeFavorite(String phone, int characterId) =>
      _storage.removeFavorite(phone, characterId);

  Future<void> saveDetail(String phone, CharacterDetail detail) =>
      _storage.saveDetail(phone, detail);

  Future<({CharacterDetail detail, bool isComplete})?> getDetail(
    String phone,
    int characterId,
  ) => _storage.getDetail(phone, characterId);
}
