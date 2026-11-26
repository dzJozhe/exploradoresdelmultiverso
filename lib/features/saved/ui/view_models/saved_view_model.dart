import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rickandmorty/core/providers.dart';
import 'package:rickandmorty/features/characters/data/models/character.dart';
import 'package:rickandmorty/features/characters/data/models/character_detail.dart';
import 'package:rickandmorty/features/characters/data/services/characters_api.dart';

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

  // [detail]: si ya se tiene (desde la pantalla de detalle), se guarda
  // directamente; si no, se descarga en segundo plano.
  Future<void> toggleFavorite(
    Character character, {
    CharacterDetail? detail,
  }) async {
    final phone = ref.read(authViewModelProvider);
    if (phone == null) return;

    final repository = ref.read(savedRepositoryProvider);
    final current = state.value ?? [];

    if (isFavorite(character.id)) {
      state = AsyncData(current.where((c) => c.id != character.id).toList());
      await repository.removeFavorite(phone, character.id);
    } else {
      state = AsyncData([...current, character]);
      await repository.addFavorite(phone, character, detail: detail);
      if (detail == null) unawaited(_downloadDetail(phone, character.id));
    }
  }

  // Guarda el detalle más reciente de un favorito (si sigue guardado).
  Future<void> saveDetail(CharacterDetail detail) async {
    final phone = ref.read(authViewModelProvider);
    if (phone == null || !isFavorite(detail.character.id)) return;
    await ref.read(savedRepositoryProvider).saveDetail(phone, detail);
  }

  Future<void> _downloadDetail(String phone, int characterId) async {
    try {
      final detail = await ref
          .read(charactersRepositoryProvider)
          .getCharacterDetail(characterId);
      await ref.read(savedRepositoryProvider).saveDetail(phone, detail);
    } on CharactersApiException {
      // Sin conexión: se completará la próxima vez que se abra el detalle.
    }
  }
}
