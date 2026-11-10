import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/routing/app_routes.dart';
import '../../widgets/placeholder_scaffold.dart';

/// Placeholder dashboard. XP, level, dan quest belum diimplementasikan.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Dashboard',
      children: [
        Text(
          'Ringkasan progres akan tampil di sini.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => context.push(AppRoutes.practice),
          icon: const Icon(Icons.videocam),
          label: const Text('Latihan'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.dictionary),
          icon: const Icon(Icons.menu_book),
          label: const Text('Kamus alfabet'),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => context.push(AppRoutes.about),
          icon: const Icon(Icons.info_outline),
          label: const Text('Tentang Kami'),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: context.read<AuthController>().signOut,
          icon: const Icon(Icons.logout),
          label: const Text('Keluar'),
        ),
      ],
    );
  }
}
