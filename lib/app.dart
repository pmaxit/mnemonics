import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/home/domain/vocabulary_word.dart';
import 'features/home/presentation/screens/learn_word_list_screen.dart';
import 'features/home/presentation/screens/learn_word_detail_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/main_scaffold.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
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
import 'features/study_session/presentation/screens/study_calendar_screen.dart';
import 'features/study_session/presentation/screens/study_plan_wizard_screen.dart';
import 'features/study_session/presentation/screens/study_day_detail_screen.dart';
import 'features/study_session/domain/study_plan_day.dart';
import 'package:flutter/material.dart';

/// Converts a [Stream] into a [Listenable] for GoRouter's refreshListenable.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier =
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges());

  // Auth routes that logged-in users should be redirected away from
  const authRoutes = ['/splash', '/welcome', '/login', '/signup'];

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final currentLocation = state.matchedLocation;

      // If logged in and on an auth route, go to home
      if (isLoggedIn && authRoutes.contains(currentLocation)) {
        return '/main/home';
      }

      // If not logged in and on a protected route, go to welcome
      if (!isLoggedIn &&
          !authRoutes.contains(currentLocation)) {
        return '/welcome';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
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
      GoRoute(
        path: '/study-plan/create',
        builder: (context, state) => const StudyPlanWizardScreen(),
      ),
      GoRoute(
        path: '/study-plan/day/:dayNum',
        builder: (context, state) {
          if (state.extra is StudyPlanDay) {
            return StudyDayDetailScreen(day: state.extra as StudyPlanDay);
          }
          final extra = state.extra as Map<String, dynamic>;
          final day = extra['day'] as StudyPlanDay;
          final date = extra['date'] as DateTime?;
          return StudyDayDetailScreen(day: day, date: date);
        },
      ),
    ],
  );
});
