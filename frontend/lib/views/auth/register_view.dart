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
import '../../widgets/common/status_pill.dart';
import 'auth_widgets.dart';

/// Halaman pendaftaran akun baru Isyaratify sesuai desain Stitch Web.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _passwordStrengthScore(String password) {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password) || password.length >= 12) {
      score++;
    }
    return score;
  }

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    auth.clearError();
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() => _showTermsError = !_acceptedTerms);
    if (!formValid || !_acceptedTerms) return;

    final ok = await auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );
    if (!ok || !mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final ext = IsyaratifyColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final passwordValue = _passwordController.text;
    final strengthScore = _passwordStrengthScore(passwordValue);

    final (strengthLabel, strengthColor) = switch (strengthScore) {
      0 => ('Kekuatan: -', scheme.onSurfaceVariant),
      1 => ('Kekuatan: Lemah', ext.feedbackError),
      2 => ('Kekuatan: Sedang', ext.onAccentYellowContainer),
      3 => ('Kekuatan: Bagus', ext.headerIndigo),
      _ => ('Kekuatan: Sangat Kuat', ext.success),
    };

    return AuthSplitLayout(
      showcase: const AuthBrandShowcase(
        badgeLabel: 'PENDAFTARAN BARU',
        headline: 'Mulai Perjalanan Belajarmu Hari Ini',
        description:
            'Buat akun untuk menyimpan riwayat latihan alfabet BISINDO, XP, lencana, dan target harian di lintas perangkat.',
        highlights: [
          AuthShowcaseHighlight(
            icon: Icons.menu_book_outlined,
            label: 'Kurikulum 26 Huruf BISINDO',
          ),
          AuthShowcaseHighlight(
            icon: Icons.bolt_rounded,
            label: 'Inferensi Lokal Hemat Kuota',
          ),
          AuthShowcaseHighlight(
            icon: Icons.sync_rounded,
            label: 'Progres Tersinkron Supabase',
          ),
        ],
        footerNote:
            'Autentikasi dikelola dengan Supabase Auth; video kamera tetap lokal.',
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
              const BrandLogo(compact: true, subtitle: 'DAFTAR AKUN'),
              TextButton.icon(
                onPressed: auth.isLoading
                    ? null
                    : () {
                        auth.clearError();
                        context.go(AppRoutes.login);
                      },
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                iconAlignment: IconAlignment.end,
                label: const Text('Masuk'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: StatusPill(
                      label: 'Pendaftaran Pengguna Baru',
                      tone: StatusPillTone.warning,
                      icon: Icons.person_add_outlined,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Buat Akun Isyaratify Baru',
                    style: AppTextStyles.headlineLg.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lengkapi data berikut untuk mulai berlatih gestur alfabet BISINDO.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const AuthDisabledActionButton(
                    icon: Icons.g_mobiledata_rounded,
                    label: 'Daftar dengan Google',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'atau daftar dengan email',
                          style: AppTextStyles.bodySm.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const AuthFieldLabel(label: 'Nama Lengkap'),
                  TextFormField(
                    controller: _nameController,
                    enabled: !auth.isLoading,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Salsabila Rahma',
                      prefixIcon: Icon(Icons.badge_outlined),
                      isDense: true,
                    ),
                    validator: (value) {
                      if ((value?.trim() ?? '').isEmpty) {
                        return 'Nama tampilan wajib diisi.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const AuthFieldLabel(label: 'Alamat Email'),
                  TextFormField(
                    controller: _emailController,
                    enabled: !auth.isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
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
                    trailing: Text(
                      strengthLabel,
                      style: AppTextStyles.labelSm.copyWith(
                        color: strengthColor,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !auth.isLoading,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
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
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(4, (index) {
                      final active = index < strengthScore;
                      return Expanded(
                        child: Container(
                          height: 5,
                          margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                          decoration: BoxDecoration(
                            color: active
                                ? strengthColor
                                : scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  const AuthFieldLabel(label: 'Ulangi Kata Sandi'),
                  TextFormField(
                    controller: _confirmPasswordController,
                    enabled: !auth.isLoading,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      hintText: 'Masukkan kembali kata sandi',
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                      isDense: true,
                      suffixIcon: IconButton(
                        tooltip: _obscureConfirm
                            ? 'Tampilkan konfirmasi kata sandi'
                            : 'Sembunyikan konfirmasi kata sandi',
                        onPressed: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Konfirmasi kata sandi belum cocok.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _acceptedTerms,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    onChanged: auth.isLoading
                        ? null
                        : (v) {
                            setState(() {
                              _acceptedTerms = v ?? false;
                              if (_acceptedTerms) _showTermsError = false;
                            });
                          },
                    title: Text(
                      'Saya menyetujui ketentuan penggunaan Isyaratify untuk latihan alfabet BISINDO tanpa menyimpan rekaman kamera.',
                      style: AppTextStyles.bodySm.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (_showTermsError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'Centang persetujuan terlebih dahulu.',
                        style: AppTextStyles.bodySm.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: 6),
                    AuthErrorBanner(message: auth.errorMessage!),
                  ],
                  const SizedBox(height: 12),
                  IsyaratifyPrimaryButton(
                    label: 'Daftar Sekarang & Mulai Belajar',
                    icon: Icons.rocket_launch_rounded,
                    isLoading: auth.isLoading,
                    expand: true,
                    onPressed: _submit,
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
                'Sudah punya akun?',
                style: AppTextStyles.bodyMd.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: auth.isLoading
                    ? null
                    : () {
                        auth.clearError();
                        context.go(AppRoutes.login);
                      },
                child: const Text('Masuk di sini'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
