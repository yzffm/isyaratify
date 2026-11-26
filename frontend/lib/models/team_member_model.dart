/// Data satu anggota tim.
class TeamMember {
  const TeamMember({
    required this.name,
    required this.role,
    this.imageAsset,
    this.githubUrl,
  });

  final String name;
  final String role;
  final String? imageAsset;
  final String? githubUrl;

  /// Huruf pertama untuk avatar (aman kalau nama kosong).
  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
}
