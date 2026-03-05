import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/home/domain/vocabulary_word.dart';
import 'features/home/presentation/screens/learn_word_list_screen.dart';
import 'features/home/presentation/screens/learn_word_detail_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/main_scaffold.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/home/presentation/screens/knowledge_tree_detail_screen.dart';
import 'features/practice/presentation/screens/practice_screen.dart';
import 'features/practice/presentation/screens/learning_session_screen.dart';
import 'features/practice/presentation/screens/details/streak_detail_screen.dart';
import 'features/practice/presentation/screens/details/words_today_detail_screen.dart';
import 'features/practice/presentation/screens/details/total_words_detail_screen.dart';
import 'features/practice/presentation/screens/details/accuracy_detail_screen.dart';
import 'features/practice/presentation/screens/details/learning_stages_detail_screen.dart';
import 'features/practice/presentation/screens/details/breakdown_detail_screen.dart';
import 'features/profile/presentation/screens/enhanced_profile_screen.dart';
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
        path: '/knowledge-tree',
        builder: (context, state) => const KnowledgeTreeDetailScreen(),
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
                builder: (context, state) => const LearningSessionScreen(),
              ),
              GoRoute(
                path: 'profile',
                builder: (context, state) => const EnhancedProfileScreen(),
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
          return LearnWordDetailScreen(
              words: words, initialIndex: initialIndex);
        },
      ),
      // Practice detail screens
      GoRoute(
        path: '/practice/streak',
        builder: (context, state) => const StreakDetailScreen(),
      ),
      GoRoute(
        path: '/practice/words-today',
        builder: (context, state) => const WordsTodayDetailScreen(),
      ),
      GoRoute(
        path: '/practice/total-words',
        builder: (context, state) => const TotalWordsDetailScreen(),
      ),
      GoRoute(
        path: '/practice/accuracy',
        builder: (context, state) => const AccuracyDetailScreen(),
      ),
      GoRoute(
        path: '/practice/learning-stages/:stage',
        builder: (context, state) {
          final stage = state.pathParameters['stage']!;
          return LearningStagesDetailScreen(stage: stage);
        },
      ),
      GoRoute(
        path: '/practice/breakdown/:type',
        builder: (context, state) {
          final type = state.pathParameters['type']!;
          return BreakdownDetailScreen(breakdownType: type);
        },
      ),
      GoRoute(
        path: '/practice/breakdown/:type/:filter',
        builder: (context, state) {
          final type = state.pathParameters['type']!;
          final filter = state.pathParameters['filter']!;
          return BreakdownDetailScreen(
              breakdownType: type, filterValue: filter);
        },
      ),
    ],
  );
});
