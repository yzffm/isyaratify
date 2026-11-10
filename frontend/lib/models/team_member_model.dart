/// Data satu anggota tim.
class TeamMember {
  const TeamMember({required this.name, required this.role});

  final String name;
  final String role;

  /// Huruf pertama untuk avatar (aman kalau nama kosong).
  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
}
