import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/attempt_model.dart';
import '../../models/progress_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/status_pill.dart';

/// Kategori tab pengaturan pada halaman [ProfileView].
enum ProfileSettingsTab { aiCamera, accountSecurity, accessibilityDisplay }

/// Kartu identitas pengguna pada bagian atas halaman Profil.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.displayName,
    required this.userEmail,
    required this.progress,
    required this.onRefresh,
    required this.onOpenProgress,
  });

  final String displayName;
  final String userEmail;
  final UserProgressModel progress;
  final VoidCallback onRefresh;
  final VoidCallback onOpenProgress;

  String get _initial {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return 'P';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.headerIndigo, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 18,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: ext.accentYellow,
                    child: Text(
                      _initial,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: ext.onAccentYellowContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ext.accentYellow.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Level ${progress.level} • ${progress.xp} XP',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: ext.accentYellow,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${progress.currentStreak} hari streak',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          displayName.trim().isEmpty
                              ? 'Pembelajar BISINDO'
                              : displayName.trim(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail.trim().isEmpty
                              ? 'Mode sinkronisasi lokal'
                              : userEmail.trim(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: onOpenProgress,
                    style: FilledButton.styleFrom(
                      backgroundColor: ext.accentYellow,
                      foregroundColor: ext.onAccentYellowContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.bar_chart_rounded, size: 18),
                    label: const Text(
                      'Lihat Detail Progres',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onRefresh,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Muat Ulang'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.16), height: 1),
          const SizedBox(height: 12),
          Text(
            'Pengenalan gestur statis A–Z berjalan on-device tanpa mengunggah frame kamera.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid 4 KPI jujur dari [ProgressController].
class ProfileKpiGrid extends StatelessWidget {
  const ProfileKpiGrid({
    super.key,
    required this.progress,
    required this.masteredLettersCount,
    required this.recentAttempts,
  });

  final UserProgressModel progress;
  final int masteredLettersCount;
  final List<PracticeAttemptModel> recentAttempts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;

    final totalRecent = recentAttempts.length;
    final correctRecent = recentAttempts.where((a) => a.isCorrect).length;
    final accuracyText = totalRecent == 0
        ? 'Belum ada'
        : '${((correctRecent / totalRecent) * 100).round()}%';
    final accuracySubtitle = totalRecent == 0
        ? 'Mulai latihan kamera dulu'
        : '$correctRecent dari $totalRecent percobaan';

    final items = [
      _KpiItem(
        icon: Icons.local_fire_department_outlined,
        tintBg: ext.accentYellowLight,
        tintFg: ext.onAccentYellowContainer,
        label: 'Streak Aktif',
        value: '${progress.currentStreak} hari',
        subtitle: 'Konsistensi latihan harian',
      ),
      _KpiItem(
        icon: Icons.bolt_rounded,
        tintBg: ext.primaryFixed,
        tintFg: ext.onPrimaryFixed,
        label: 'Total XP',
        value: '${progress.xp} XP',
        subtitle: 'Level ${progress.level}',
      ),
      _KpiItem(
        icon: Icons.pan_tool_outlined,
        tintBg: ext.successLight,
        tintFg: ext.onSuccessContainer,
        label: 'Huruf Selesai',
        value: '$masteredLettersCount / 26',
        subtitle: 'Alfabet BISINDO statis',
      ),
      _KpiItem(
        icon: Icons.track_changes_outlined,
        tintBg: ext.primaryFixed,
        tintFg: theme.colorScheme.primary,
        label: 'Akurasi Keseluruhan',
        value: accuracyText,
        subtitle: accuracySubtitle,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 920 ? 4 : (width >= 540 ? 2 : 1);
        const spacing = 14.0;
        final itemWidth = (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.tintBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: item.tintFg, size: 20),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        item.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _KpiItem {
  const _KpiItem({
    required this.icon,
    required this.tintBg,
    required this.tintFg,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color tintBg;
  final Color tintFg;
  final String label;
  final String value;
  final String subtitle;
}

/// Kartu ringkasan riwayat latihan terbaru + CTA menuju `/progress`.
class ProfileRecentProgressCard extends StatelessWidget {
  const ProfileRecentProgressCard({
    super.key,
    required this.masteredLettersCount,
    required this.earnedBadgesCount,
    required this.totalBadgesCount,
    required this.recentAttempts,
    required this.onOpenProgress,
    required this.onStartPractice,
  });

  final int masteredLettersCount;
  final int earnedBadgesCount;
  final int totalBadgesCount;
  final List<PracticeAttemptModel> recentAttempts;
  final VoidCallback onOpenProgress;
  final VoidCallback onStartPractice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;
    final masteryRatio = (masteredLettersCount / 26).clamp(0.0, 1.0);
    final preview = recentAttempts.take(4).toList();

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Ringkasan Progres & Riwayat',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton.icon(
                onPressed: onOpenProgress,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Detail Progres'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penguasaan Alfabet A–Z ($masteredLettersCount/26 huruf)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: masteryRatio,
                        minHeight: 8,
                        backgroundColor: ext.borderSubtle,
                        valueColor: AlwaysStoppedAnimation<Color>(ext.success),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              StatusPill(
                label: '$earnedBadgesCount/$totalBadgesCount Lencana',
                tone: StatusPillTone.info,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Aktivitas Latihan Terakhir',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (preview.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ext.surfaceCanvas,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ext.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Belum ada riwayat latihan tersimpan.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hanya metadata hasil (huruf target, prediksi, skor, waktu) yang dicatat tanpa foto/video kamera.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: onStartPractice,
                    icon: const Icon(Icons.videocam_outlined, size: 18),
                    label: const Text('Mulai Latihan Kamera'),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: preview.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final attempt = preview[index];
                final scorePct = (attempt.confidence * 100).round();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: ext.surfaceCanvas,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ext.borderSubtle),
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: attempt.isCorrect
                                ? ext.successLight
                                : ext.feedbackErrorLight,
                            child: Text(
                              (attempt.targetLetter ?? '').isEmpty
                                  ? attempt.predictedLetter
                                  : attempt.targetLetter!,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: attempt.isCorrect
                                    ? ext.success
                                    : ext.feedbackError,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Target ${(attempt.targetLetter ?? '').isEmpty ? 'Bebas' : attempt.targetLetter!} • Prediksi ${attempt.predictedLetter}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Skor model: $scorePct% • Platform: ${attempt.platform}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      StatusPill(
                        label: attempt.isCorrect ? 'Cocok' : 'Ulangi',
                        tone: attempt.isCorrect
                            ? StatusPillTone.success
                            : StatusPillTone.warning,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Panel pengaturan interaktif + kartu tautan wajib ke halaman About Us.
class ProfileSettingsPanel extends StatelessWidget {
  const ProfileSettingsPanel({
    super.key,
    required this.selectedTab,
    required this.mirrorCameraPreview,
    required this.showLandmarkOverlay,
    required this.showTextFeedbackBanner,
    required this.displayName,
    required this.userEmail,
    required this.onSelectTab,
    required this.onMirrorChanged,
    required this.onOverlayChanged,
    required this.onFeedbackBannerChanged,
    required this.onOpenAbout,
    required this.onLogout,
  });

  final ProfileSettingsTab selectedTab;
  final bool mirrorCameraPreview;
  final bool showLandmarkOverlay;
  final bool showTextFeedbackBanner;
  final String displayName;
  final String userEmail;
  final ValueChanged<ProfileSettingsTab> onSelectTab;
  final ValueChanged<bool> onMirrorChanged;
  final ValueChanged<bool> onOverlayChanged;
  final ValueChanged<bool> onFeedbackBannerChanged;
  final VoidCallback onOpenAbout;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengaturan Aplikasi & Preferensi',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Preferensi lokal sesi kamera, informasi keamanan data, dan panduan aksesibilitas.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('AI & Kamera'),
                    selected: selectedTab == ProfileSettingsTab.aiCamera,
                    onSelected: (_) => onSelectTab(ProfileSettingsTab.aiCamera),
                  ),
                  ChoiceChip(
                    label: const Text('Akun & Keamanan'),
                    selected: selectedTab == ProfileSettingsTab.accountSecurity,
                    onSelected: (_) =>
                        onSelectTab(ProfileSettingsTab.accountSecurity),
                  ),
                  ChoiceChip(
                    label: const Text('Aksesibilitas & Tampilan'),
                    selected:
                        selectedTab == ProfileSettingsTab.accessibilityDisplay,
                    onSelected: (_) =>
                        onSelectTab(ProfileSettingsTab.accessibilityDisplay),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (selectedTab == ProfileSettingsTab.aiCamera) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pratinjau kamera cermin (Mirror)'),
                  subtitle: const Text(
                    'Membalik tampilan pratinjau horizontal saat berlatih di browser/perangkat.',
                  ),
                  value: mirrorCameraPreview,
                  onChanged: onMirrorChanged,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tampilkan overlay titik tangan'),
                  subtitle: const Text(
                    'Menampilkan 21 titik landmark MediaPipe di atas area pratinjau bila tersedia.',
                  ),
                  value: showLandmarkOverlay,
                  onChanged: onOverlayChanged,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ext.surfaceCanvas,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ext.borderSubtle),
                  ),
                  child: Text(
                    'Pemrosesan hand tracking dan klasifikasi gestur statis alfabet BISINDO A–Z berjalan lokal di perangkat tanpa mengirim frame video ke backend.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ] else if (selectedTab == ProfileSettingsTab.accountSecurity) ...[
                _SettingInfoTile(
                  icon: Icons.person_outline,
                  title: 'Nama Tampilan Aktif',
                  subtitle: displayName.trim().isEmpty
                      ? 'Pembelajar BISINDO'
                      : displayName.trim(),
                ),
                const SizedBox(height: 8),
                _SettingInfoTile(
                  icon: Icons.mail_outline,
                  title: 'Email Akun',
                  subtitle: userEmail.trim().isEmpty
                      ? 'Belum terhubung dengan sesi daring'
                      : userEmail.trim(),
                ),
                const SizedBox(height: 8),
                const _SettingInfoTile(
                  icon: Icons.shield_outlined,
                  title: 'Privasi Data & Row Level Security',
                  subtitle:
                      'Aplikasi hanya mencatat metadata hasil latihan (target, prediksi, skor, timestamp). Gambar/video kamera tidak pernah disimpan, dan email pribadi tidak ditampilkan di papan peringkat.',
                ),
              ] else ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Teks & ikon pendamping status'),
                  subtitle: const Text(
                    'Menyertakan label teks/ikon pada setiap status benar, ragu, atau ulangi agar tidak hanya bergantung pada warna.',
                  ),
                  value: showTextFeedbackBanner,
                  onChanged: onFeedbackBannerChanged,
                ),
                const SizedBox(height: 8),
                const _SettingInfoTile(
                  icon: Icons.contrast_outlined,
                  title: 'Tema Antarmuka Saat Ini',
                  subtitle:
                      'Menggunakan tema terang kontras tinggi (Material 3 + Plus Jakarta Sans). Dukungan pengalih tema gelap dijadwalkan pada fase pengembangan berikutnya.',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ext.primaryFixed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tentang Aplikasi & Pengembang',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Visi produk dan profil lengkap 7 anggota tim pengembang Isyaratify.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: onOpenAbout,
                    icon: const Icon(Icons.groups_outlined, size: 18),
                    label: const Text('Tentang Isyaratify'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onLogout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ext.feedbackError,
                      side: BorderSide(color: ext.feedbackError),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Keluar Sesi (Logout)'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingInfoTile extends StatelessWidget {
  const _SettingInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<IsyaratifyColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ext.surfaceCanvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ext.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
