import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'profile_widgets.dart';

/// Halaman Profil Pembelajar & Pengaturan Isyaratify.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  ProfileSettingsTab _selectedTab = ProfileSettingsTab.aiCamera;
  bool _mirrorCameraPreview = true;
  bool _showLandmarkOverlay = true;
  bool _showTextFeedbackBanner = true;

  Future<void> _confirmAndSignOut(BuildContext context) async {
    final authCtrl = context.read<AuthController>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari Isyaratify?'),
          content: const Text(
            'Sesi akun kamu akan diakhiri. Progres lokal yang belum tersinkron tetap tersimpan di perangkat ini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await authCtrl.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<IsyaratifyColors>()!;
    final layoutSize = AppBreakpoints.of(context);
    final isExpanded = layoutSize == AppLayoutSize.expanded;

    final authCtrl = context.watch<AuthController>();
    final progressCtrl = context.watch<ProgressController>();
    final horizontalPad = layoutSize == AppLayoutSize.compact ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: ext.surfaceCanvas,
      body: RefreshIndicator(
        onRefresh: progressCtrl.refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPad,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeaderCard(
                    displayName: authCtrl.displayName,
                    userEmail: authCtrl.userEmail,
                    progress: progressCtrl.progress,
                    onRefresh: progressCtrl.refreshAll,
                    onOpenProgress: () => context.push(AppRoutes.progress),
                  ),
                  const SizedBox(height: 20),
                  ProfileKpiGrid(
                    progress: progressCtrl.progress,
                    masteredLettersCount: progressCtrl.masteredLettersCount,
                    recentAttempts: progressCtrl.recentAttempts,
                  ),
                  const SizedBox(height: 24),
                  if (isExpanded)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: ProfileRecentProgressCard(
                            masteredLettersCount:
                                progressCtrl.masteredLettersCount,
                            earnedBadgesCount: progressCtrl.earnedBadgesCount,
                            totalBadgesCount: progressCtrl.badges.length,
                            recentAttempts: progressCtrl.recentAttempts,
                            onOpenProgress: () =>
                                context.push(AppRoutes.progress),
                            onStartPractice: () =>
                                context.push(AppRoutes.practice),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 6,
                          child: ProfileSettingsPanel(
                            selectedTab: _selectedTab,
                            mirrorCameraPreview: _mirrorCameraPreview,
                            showLandmarkOverlay: _showLandmarkOverlay,
                            showTextFeedbackBanner: _showTextFeedbackBanner,
                            displayName: authCtrl.displayName,
                            userEmail: authCtrl.userEmail,
                            onSelectTab: (tab) =>
                                setState(() => _selectedTab = tab),
                            onMirrorChanged: (val) =>
                                setState(() => _mirrorCameraPreview = val),
                            onOverlayChanged: (val) =>
                                setState(() => _showLandmarkOverlay = val),
                            onFeedbackBannerChanged: (val) =>
                                setState(() => _showTextFeedbackBanner = val),
                            onOpenAbout: () => context.push(AppRoutes.about),
                            onLogout: () => _confirmAndSignOut(context),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    ProfileRecentProgressCard(
                      masteredLettersCount: progressCtrl.masteredLettersCount,
                      earnedBadgesCount: progressCtrl.earnedBadgesCount,
                      totalBadgesCount: progressCtrl.badges.length,
                      recentAttempts: progressCtrl.recentAttempts,
                      onOpenProgress: () => context.push(AppRoutes.progress),
                      onStartPractice: () => context.push(AppRoutes.practice),
                    ),
                    const SizedBox(height: 20),
                    ProfileSettingsPanel(
                      selectedTab: _selectedTab,
                      mirrorCameraPreview: _mirrorCameraPreview,
                      showLandmarkOverlay: _showLandmarkOverlay,
                      showTextFeedbackBanner: _showTextFeedbackBanner,
                      displayName: authCtrl.displayName,
                      userEmail: authCtrl.userEmail,
                      onSelectTab: (tab) => setState(() => _selectedTab = tab),
                      onMirrorChanged: (val) =>
                          setState(() => _mirrorCameraPreview = val),
                      onOverlayChanged: (val) =>
                          setState(() => _showLandmarkOverlay = val),
                      onFeedbackBannerChanged: (val) =>
                          setState(() => _showTextFeedbackBanner = val),
                      onOpenAbout: () => context.push(AppRoutes.about),
                      onLogout: () => _confirmAndSignOut(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
