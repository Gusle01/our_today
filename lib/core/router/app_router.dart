import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:our_today/core/widgets/app_shell.dart';
import 'package:our_today/features/auth/presentation/providers/auth_providers.dart';
import 'package:our_today/features/auth/presentation/screens/my_screen.dart';
import 'package:our_today/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:our_today/features/auth/presentation/screens/splash_screen.dart';
import 'package:our_today/features/couple/presentation/screens/couple_history_screen.dart';
import 'package:our_today/features/couple/presentation/screens/couple_tab_screen.dart';
import 'package:our_today/features/solo/presentation/screens/emotion_screen.dart';
import 'package:our_today/features/solo/presentation/screens/history_screen.dart';
import 'package:our_today/features/solo/presentation/screens/home_screen.dart';
import 'package:our_today/features/solo/presentation/screens/praise_screen.dart';
import 'package:our_today/features/solo/presentation/screens/question_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authRepositoryProvider).authStateChanges(),
    ),
    redirect: (context, state) {
      final loggedIn =
          ref.read(authRepositoryProvider).currentUser != null;
      final loc = state.matchedLocation;

      if (!loggedIn) {
        return loc == '/onboarding' ? null : '/onboarding';
      }
      if (loc == '/' || loc == '/onboarding') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/onboarding', builder: (_, __) => const OnboardingScreen()),

      // 풀스크린(쉘 위에 push)
      GoRoute(path: '/question', builder: (_, __) => const QuestionScreen()),
      GoRoute(path: '/emotion', builder: (_, __) => const EmotionScreen()),
      GoRoute(path: '/praise', builder: (_, __) => const PraiseScreen()),
      GoRoute(
          path: '/couple/history',
          builder: (_, __) => const CoupleHistoryScreen()),

      // 바텀네비 쉘
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/history', builder: (_, __) => const HistoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/couple', builder: (_, __) => const CoupleTabScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/my', builder: (_, __) => const MyScreen()),
          ]),
        ],
      ),
    ],
  );
});

/// Stream 을 Listenable 로 변환하는 go_router 공식 레시피.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription =
        stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
