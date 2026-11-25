import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rickandmorty/core/providers.dart';
import 'package:rickandmorty/features/characters/data/models/character.dart';

class SavedViewModel extends AsyncNotifier<List<Character>> {
  @override
  Future<List<Character>> build() async {
    // Se recarga cuando cambia la sesión.
    final phone = ref.watch(authViewModelProvider);
    if (phone == null) return [];
    return ref.read(savedRepositoryProvider).getFavorites(phone);
  }

  bool isFavorite(int characterId) =>
      (state.value ?? []).any((c) => c.id == characterId);

  Future<void> toggleFavorite(Character character) async {
    final phone = ref.read(authViewModelProvider);
    if (phone == null) return;

    final repository = ref.read(savedRepositoryProvider);
    final current = state.value ?? [];

    if (isFavorite(character.id)) {
      state = AsyncData(current.where((c) => c.id != character.id).toList());
      await repository.removeFavorite(phone, character.id);
    } else {
      state = AsyncData([...current, character]);
      await repository.addFavorite(phone, character);
    }
  }
}
