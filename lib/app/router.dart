import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rickandmorty/core/providers.dart';
import 'package:rickandmorty/features/auth/ui/views/login_view.dart';
import 'package:rickandmorty/features/auth/ui/views/verification_view.dart';
import 'package:rickandmorty/features/characters/views/character_detail_view.dart';
import 'package:rickandmorty/features/characters/views/characters_view.dart';
import 'package:rickandmorty/features/saved/views/saved_view.dart';

final appRouter = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoginActive = ref.read(authViewModelProvider) != null;
      final currentLocation =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/verify';

      // Si NO ha iniciado sesión y NO está en /login ni /verify -> mándalo a /login
      if (!isLoginActive && !currentLocation) {
        return '/login';
      }

      // Si YA inició sesión y está en /login o /verify -> mándalo a la pantalla principal
      if (isLoginActive && currentLocation) {
        return '/characters';
      }
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginView()),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final data = state.extra as ({String phone, String code});
          return VerificationView(
            phoneNumer: data.phone,
            verificationCode: data.code,
          );
        },
      ),
      GoRoute(
        path: '/characters',
        builder: (_, _) => const CharactersView(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => CharacterDetailView(
              characterId: int.tryParse(state.pathParameters['id'] ?? ''),
            ),
          ),
        ],
      ),
      GoRoute(path: '/saved', builder: (_, _) => const SavedView()),
    ],
  );
});
