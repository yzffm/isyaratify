import 'package:flutter/material.dart';

import '../../models/team_member_model.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  static const List<TeamMember> _teamMembers = [
    TeamMember(
      name: 'Yusuf Maulana',
      role: 'Project Lead, Requirement, Dokumentasi',
    ),
    TeamMember(name: 'Salsabila', role: 'Flutter UI/UX & Design System'),
    TeamMember(name: 'Ayesha', role: 'Flutter App Logic & State Management'),
    TeamMember(name: 'Siska', role: 'Web Camera & MediaPipe JS'),
    TeamMember(name: 'Wishang', role: 'Android Camera & MediaPipe Native'),
    TeamMember(name: 'Muhammad Ilham', role: 'ML/Data Engineer & Hugging Face'),
    TeamMember(name: 'Ellyka', role: 'Supabase, QA, DevOps'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Isyarat Quest'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Visi Produk ----
            Card(
              elevation: 0,
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Visi Produk',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Membuat pengalaman belajar alfabet BISINDO yang '
                      'interaktif, mudah dicoba, dan memberi umpan balik '
                      'langsung melalui kamera.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ---- Tim Pengembang ----
            Text(
              'Tim Pengembang (${_teamMembers.length} Anggota)',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _teamMembers.length,
              itemBuilder: (context, index) {
                final member = _teamMembers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.secondary,
                      child: Text(
                        member.initial,
                        style: TextStyle(color: colorScheme.onSecondary),
                      ),
                    ),
                    title: Text(
                      member.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(member.role),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ---- Versi ----
            Center(
              child: Text(
                'Versi 0.1 — Planning Baseline\n'
                'Target: Flutter Web & Android APK',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
