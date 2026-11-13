import 'package:go_router/go_router.dart';

import '../../controllers/auth_controller.dart';
import '../../platform/hand_tracking_platform.dart';
import '../../services/hand_tracking_service.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/register_view.dart';
import '../../views/dictionary/dictionary_view.dart';
import '../../views/home/dashboard_view.dart';
import '../../views/leaderboard/leaderboard_view.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/practice/practice_view.dart';
import '../../views/profile/about_us_view.dart';
import '../../views/profile/profile_view.dart';
import '../../views/progress/progress_view.dart';
import '../../views/quest/quest_view.dart';
import '../../views/splash/splash_view.dart';
import '../../widgets/shell/app_shell.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static GoRouter create(
    AuthController auth, {
    HandTrackingService Function() handTrackingServiceFactory =
        createPlatformHandTrackingService,
  }) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: auth,
      redirect: (context, state) {
        final path = state.uri.path;
        if (path == AppRoutes.root) {
          return auth.isAuthenticated ? AppRoutes.home : AppRoutes.login;
        }
        final isPublic = AppRoutes.publicRoutes.contains(path);
        if (!auth.isAuthenticated && !isPublic) {
          final from = state.uri.toString();
          if (from.isNotEmpty && from != AppRoutes.home) {
            return '${AppRoutes.login}?from=${Uri.encodeQueryComponent(from)}';
          }
          return AppRoutes.login;
        }
        if (auth.isAuthenticated &&
            (path == AppRoutes.login ||
                path == AppRoutes.register ||
                path == AppRoutes.onboarding)) {
          final from = state.uri.queryParameters['from'];
          if (from != null &&
              from.startsWith('/') &&
              !from.startsWith('//') &&
              from != AppRoutes.login &&
              from != AppRoutes.register &&
              from != AppRoutes.onboarding &&
              from != AppRoutes.splash) {
            return from;
          }
          return AppRoutes.home;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashView(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingView(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterView(),
        ),
        ShellRoute(
          builder: (context, state, child) =>
              AppShell(location: state.uri.path, child: child),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const DashboardView(),
            ),
            GoRoute(
              path: AppRoutes.dictionary,
              builder: (context, state) => const DictionaryView(),
            ),
            GoRoute(
              path: AppRoutes.practice,
              builder: (context, state) {
                final targetLetter = state.uri.queryParameters['target'];
                return PracticeView(
                  serviceFactory: handTrackingServiceFactory,
                  initialTargetLetter: targetLetter,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.quest,
              builder: (context, state) => const QuestView(),
            ),
            GoRoute(
              path: AppRoutes.leaderboard,
              builder: (context, state) => const LeaderboardView(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileView(),
            ),
            GoRoute(
              path: AppRoutes.progress,
              builder: (context, state) => const ProgressView(),
            ),
            GoRoute(
              path: AppRoutes.about,
              builder: (context, state) => const AboutUsView(),
            ),
          ],
        ),
      ],
    );
  }
}
