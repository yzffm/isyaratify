/// Path route terpusat agar tidak tersebar sebagai string literal.
abstract final class AppRoutes {
  static const root = '/';
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const dictionary = '/dictionary';
  static const practice = '/practice';
  static const quest = '/quest';
  static const progress = '/progress';
  static const about = '/about';

  /// Buat URI latihan dengan huruf target opsional (`/practice?target=A`).
  static String practiceWithTarget([String? letter]) {
    if (letter == null || letter.trim().isEmpty) {
      return practice;
    }
    return '$practice?target=${Uri.encodeQueryComponent(letter.trim().toUpperCase())}';
  }

  /// Route yang boleh diakses tanpa login.
  static const publicRoutes = {splash, login};
}
