import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:cybershield/core/utils/validators.dart';
import 'package:cybershield/providers/auth_provider.dart';
import 'package:cybershield/widgets/tactile_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      context.go('/home');
    } else if (authState.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authState.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _BackgroundBlobs()),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    border: Border(
                      bottom: BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CyberShield',
                        style: AppTypography.headlineLg.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 0.1,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'اللغة الإنجليزية غير متاحة حالياً',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.language, size: 18),
                        label: const Text('English'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: const Border(
                                bottom: BorderSide(
                                  color: AppColors.onPrimary,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.shield,
                              color: AppColors.primary,
                              size: 32,
                              fill: 1.0,
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 24),
                          Text(
                            'مرحباً بك مجدداً',
                            style: AppTypography.headlineXl.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                          const SizedBox(height: 8),
                          Text(
                            'قم بتسجيل الدخول للوصول إلى محيطك الرقمي الآمن',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: const Border(
                                top: BorderSide(
                                  color: AppColors.outlineVariant,
                                ),
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'البريد الإلكتروني',
                                    style: AppTypography.labelMd.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _emailController,
                                    validator: Validators.email,
                                    keyboardType: TextInputType.emailAddress,
                                    style: AppTypography.bodyMd.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'name@company.com',
                                      prefixIcon: Icon(
                                        Icons.mail,
                                        color: AppColors.outline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'كلمة المرور',
                                        style: AppTypography.labelMd.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        'هل نسيت كلمة المرور؟',
                                        style: AppTypography.labelSm.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _passwordController,
                                    validator: Validators.password,
                                    obscureText: _obscurePassword,
                                    style: AppTypography.bodyMd.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      prefixIcon: const Icon(
                                        Icons.lock,
                                        color: AppColors.outline,
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                        child: Icon(
                                          _obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: AppColors.outline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  TactileButton(
                                    label: 'تسجيل الدخول',
                                    onPressed: _isLoading
                                        ? () {}
                                        : _handleLogin,
                                    icon: Icons.arrow_back,
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: AppColors.outlineVariant),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  'أو الاستمرار بواسطة',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.outline,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: AppColors.outlineVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'تسجيل الدخول عبر Google غير متاح حالياً',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.g_mobiledata,
                                    size: 20,
                                  ),
                                  label: const Text('Google'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.onSurface,
                                    side: const BorderSide(
                                      color: AppColors.outlineVariant,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'تسجيل الدخول عبر Apple غير متاح حالياً',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.apple, size: 20),
                                  label: const Text('Apple'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.onSurface,
                                    side: const BorderSide(
                                      color: AppColors.outlineVariant,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () => context.go('/register'),
                            child: Text.rich(
                              TextSpan(
                                text: 'مستخدم جديد؟ ',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'إنشاء حساب',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0x4D4C4451))),
                  ),
                  child: Text(
                    'بتسجيل الدخول، أنت توافق على شروط الخدمة وسياسة الخصوصية الخاصة بنا\n© 2024 CYBERSHIELD TECHNOLOGY CO.',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 10,
                      color: AppColors.outline,
                    ),
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

class _BackgroundBlobs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          left: -60,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
            ),
          ).animate().fadeIn(duration: 1200.ms),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryContainer.withValues(alpha: 0.1),
            ),
          ).animate().fadeIn(duration: 1200.ms, delay: 300.ms),
        ),
      ],
    );
  }
}
