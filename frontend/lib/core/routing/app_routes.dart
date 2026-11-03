/// Path route terpusat agar tidak tersebar sebagai string literal.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const dictionary = '/dictionary';
  static const practice = '/practice';

  /// Route yang boleh diakses tanpa login.
  static const publicRoutes = {splash, login};
}
