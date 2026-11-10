import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/placeholder_scaffold.dart';

/// Halaman autentikasi (Masuk & Daftar) yang terhubung ke [AuthController]
/// dan Supabase Auth.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isRegisterMode = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthController auth) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (_isRegisterMode) {
      await auth.signUp(
        email: email,
        password: password,
        displayName: _displayNameController.text.trim(),
      );
    } else {
      await auth.signInWithPassword(email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final theme = Theme.of(context);

    return PlaceholderScaffold(
      title: _isRegisterMode ? 'Daftar Akun' : 'Masuk',
      children: [
        Text(
          'Masuk dengan akun Isyaratify untuk menyimpan XP, level, penguasaan '
          'huruf BISINDO, dan progres misi Anda.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        if (_isRegisterMode) ...[
          TextField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Nama tampilan',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            enabled: !auth.isLoading,
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !auth.isLoading,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Kata sandi',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          onSubmitted: (_) => _submit(auth),
          enabled: !auth.isLoading,
        ),
        if (auth.errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    auth.errorMessage!,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: auth.isLoading ? null : () => _submit(auth),
          icon: auth.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_isRegisterMode ? Icons.person_add : Icons.login),
          label: Text(
            _isRegisterMode ? 'Buat Akun Baru' : 'Masuk dengan Email',
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: auth.isLoading
              ? null
              : () {
                  auth.clearError();
                  setState(() {
                    _isRegisterMode = !_isRegisterMode;
                  });
                },
          child: Text(
            _isRegisterMode
                ? 'Sudah punya akun? Masuk di sini'
                : 'Belum punya akun? Daftar sekarang',
          ),
        ),
        const Divider(height: 28),
        OutlinedButton(
          onPressed: auth.isLoading ? null : auth.signInPlaceholder,
          child: const Text('Lanjut (placeholder)'),
        ),
      ],
    );
  }
}
