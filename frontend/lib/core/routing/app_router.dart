import 'package:go_router/go_router.dart';

import '../../controllers/auth_controller.dart';
import '../../views/auth/login_view.dart';
import '../../views/dictionary/dictionary_view.dart';
import '../../views/home/dashboard_view.dart';
import '../../views/practice/practice_view.dart';
import '../../views/profile/about_us_screen.dart';
import '../../views/splash/splash_view.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static GoRouter create(AuthController auth) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: auth,
      redirect: (context, state) {
        final path = state.uri.path;
        final isPublic = AppRoutes.publicRoutes.contains(path);
        if (!auth.isAuthenticated && !isPublic) {
          return AppRoutes.login;
        }
        if (auth.isAuthenticated && path == AppRoutes.login) {
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
          path: AppRoutes.login,
          builder: (context, state) => const LoginView(),
        ),
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
          builder: (context, state) => const PracticeView(),
        ),
        GoRoute(
          path: AppRoutes.about,
          builder: (context, state) => const AboutUsScreen(),
        ),
      ],
    );
  }
}