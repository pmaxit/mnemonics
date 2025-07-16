import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/home/domain/vocabulary_word.dart';
import 'features/home/presentation/screens/learn_word_list_screen.dart';
import 'features/home/presentation/screens/learn_word_detail_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/main_scaffold.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/practice/presentation/screens/practice_screen.dart';
import 'features/practice/presentation/screens/timer_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/word-list/:setId',
        builder: (context, state) {
          final setId = state.pathParameters['setId']!;
          return LearnWordListScreen(setId: setId);
        },
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const SizedBox.shrink(), // dummy widget
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainScaffold(child: child),
            routes: [
              GoRoute(
                path: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: 'practice',
                builder: (context, state) => const PracticeScreen(),
              ),
              GoRoute(
                path: 'timer',
                builder: (context, state) => const TimerScreen(),
              ),
              GoRoute(
                path: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/flashcards',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final words = extra?['words'] as List<VocabularyWord>? ?? [];
          final initialIndex = extra?['initialIndex'] as int? ?? 0;
          return LearnWordDetailScreen(words: words, initialIndex: initialIndex);
        },
      ),
    ],
  );
}); 