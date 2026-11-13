import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/brand/brand_logo.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/primary_button.dart';
import 'auth_widgets.dart';

/// Halaman masuk akun Isyaratify sesuai desain split-column Web Stitch.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    auth.clearError();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await auth.signInWithPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!ok || !mounted) return;
    context.go(AppRoutes.home);
  }

  void _showForgotPasswordInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Pemulihan kata sandi mengikuti konfigurasi email Supabase Auth.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    return AuthSplitLayout(
      showcase: const AuthBrandShowcase(
        badgeLabel: 'WEB MVP',
        headline: 'Masuk & Lanjutkan Latihan Alfabet BISINDO',
        description:
            'Pelajari 26 gestur alfabet BISINDO dengan kamus visual, latihan kamera real-time di perangkat, dan misi harian.',
        highlights: [
          AuthShowcaseHighlight(
            icon: Icons.sign_language_rounded,
            label: '26 Huruf BISINDO A–Z',
          ),
          AuthShowcaseHighlight(
            icon: Icons.videocam_outlined,
            label: 'Deteksi Kamera On-Device',
          ),
          AuthShowcaseHighlight(
            icon: Icons.military_tech_outlined,
            label: 'Quest, XP & Leaderboard',
          ),
        ],
      ),
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => context.go(AppRoutes.onboarding),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.auto_awesome_outlined, size: 16),
                label: const Text('Lihat Pengenalan'),
              ),
              const BrandLogo(compact: true, subtitle: 'MASUK'),
            ],
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Selamat Datang Kembali',
                    style: AppTextStyles.headlineLg.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Masuk ke akun Isyaratify untuk menyinkronkan progres belajarmu.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const AuthFieldLabel(label: 'Alamat Email'),
                  TextFormField(
                    controller: _emailController,
                    enabled: !auth.isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'nama@email.com',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                      isDense: true,
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty || !email.contains('@')) {
                        return 'Masukkan alamat email yang valid.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  AuthFieldLabel(
                    label: 'Kata Sandi',
                    trailing: InkWell(
                      onTap: _showForgotPasswordInfo,
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: AppTextStyles.labelMd.copyWith(
                          color: ext.headerIndigo,
                        ),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !auth.isLoading,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Minimal 6 karakter',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      isDense: true,
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Tampilkan kata sandi'
                            : 'Sembunyikan kata sandi',
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').length < 6) {
                        return 'Kata sandi minimal 6 karakter.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        visualDensity: VisualDensity.compact,
                        onChanged: auth.isLoading
                            ? null
                            : (v) => setState(() => _rememberMe = v ?? true),
                      ),
                      Expanded(
                        child: Text(
                          'Ingat sesi pada perangkat ini',
                          style: AppTextStyles.bodySm.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    AuthErrorBanner(message: auth.errorMessage!),
                  ],
                  const SizedBox(height: 10),
                  IsyaratifyPrimaryButton(
                    label: 'Masuk Sekarang',
                    icon: Icons.arrow_forward_rounded,
                    isLoading: auth.isLoading,
                    expand: true,
                    height: 46,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: auth.isLoading ? null : auth.signInPlaceholder,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 42),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Lanjut (placeholder)'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Opsi Lainnya',
                          style: AppTextStyles.labelSm.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const AuthDisabledActionButton(
                    icon: Icons.g_mobiledata_rounded,
                    label: 'Lanjut dengan Google',
                  ),
                  const SizedBox(height: 8),
                  const AuthDisabledActionButton(
                    icon: Icons.videocam_outlined,
                    label: 'Coba Mode Tamu',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Text(
                'Belum punya akun?',
                style: AppTextStyles.bodyMd.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: auth.isLoading
                    ? null
                    : () {
                        auth.clearError();
                        context.go(AppRoutes.register);
                      },
                child: const Text('Daftar gratis di sini'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
