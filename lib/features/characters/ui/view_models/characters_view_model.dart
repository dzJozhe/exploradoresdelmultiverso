import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rickandmorty/core/providers.dart';
import 'package:rickandmorty/features/characters/data/models/character.dart';
import 'package:rickandmorty/features/characters/data/services/characters_api.dart';

class CharactersState {
  final List<Character> characters;
  final String query; // '' = sin filtro
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;
  final bool isConnectionError;

  const CharactersState({
    this.characters = const [],
    this.query = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
    this.isConnectionError = false,
  });

  CharactersState copyWith({
    List<Character>? characters,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
    bool? isConnectionError,
  }) {
    return CharactersState(
      characters: characters ?? this.characters,
      query: query,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
      isConnectionError: isConnectionError ?? false,
    );
  }
}

class CharactersViewModel extends Notifier<CharactersState> {
  Timer? _debounce;
  // Permite descartar respuestas de búsquedas anteriores.
  int _requestId = 0;

  @override
  CharactersState build() {
    ref.onDispose(() => _debounce?.cancel());
    Future.microtask(loadCharacters);
    return const CharactersState(isLoading: true);
  }

  void search(String text) {
    final query = text.trim();
    _debounce?.cancel();
    if (query == state.query) return;
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => loadCharacters(query: query),
    );
  }

  void clearSearch() {
    _debounce?.cancel();
    loadCharacters(query: '');
  }

  // Sin [query] repite la búsqueda actual.
  Future<void> loadCharacters({String? query}) async {
    final q = query ?? state.query;
    final requestId = ++_requestId;
    state = CharactersState(isLoading: true, query: q);

    try {
      final result = await ref
          .read(charactersRepositoryProvider)
          .getCharacters(page: 1, name: q);
      if (requestId != _requestId) return;
      state = CharactersState(
        characters: result.characters,
        query: q,
        hasMore: result.hasNext,
        page: 1,
      );
    } on CharactersApiException catch (e) {
      if (requestId != _requestId) return;
      state = CharactersState(
        query: q,
        error: e.message,
        isConnectionError: e.isConnectionError,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final requestId = _requestId;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final result = await ref
          .read(charactersRepositoryProvider)
          .getCharacters(page: nextPage, name: state.query);
      if (requestId != _requestId) return;
      state = state.copyWith(
        characters: [...state.characters, ...result.characters],
        hasMore: result.hasNext,
        page: nextPage,
        isLoadingMore: false,
      );
    } on CharactersApiException catch (e) {
      if (requestId != _requestId) return;
      state = state.copyWith(
        isLoadingMore: false,
        error: e.message,
        isConnectionError: e.isConnectionError,
      );
    }
  }
}
