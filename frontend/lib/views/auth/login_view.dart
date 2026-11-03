import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/placeholder_scaffold.dart';

/// Placeholder login. Belum memanggil Supabase Auth.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Masuk',
      children: [
        const TextField(
          decoration: InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          enabled: false,
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(labelText: 'Kata sandi'),
          obscureText: true,
          enabled: false,
        ),
        const SizedBox(height: 8),
        Text(
          'Autentikasi belum diimplementasikan. Tombol di bawah hanya untuk '
          'menjelajahi kerangka aplikasi.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: context.read<AuthController>().signInPlaceholder,
          child: const Text('Lanjut (placeholder)'),
        ),
      ],
    );
  }
}
