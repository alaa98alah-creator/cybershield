import 'package:cybershield/core/constants/app_constants.dart';
import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:cybershield/services/token_storage.dart';
import 'package:cybershield/widgets/scan_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;
    final hasToken = await TokenStorage().hasToken();
    if (!mounted) return;
    context.go(hasToken ? '/home' : '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.background),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _DotPatternPainter())),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Text(
                    'وحدة الاستخبارات السيبرانية',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 0.1,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 8),
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const Spacer(),
                  const ScanVisualizer(
                    size: 176,
                    showLabel: false,
                    centerIcon: Icons.shield,
                  ).animate().fadeIn(duration: 800.ms),
                  const SizedBox(height: 40),
                  Text(
                    'CyberShield',
                    style: AppTypography.headlineXl.copyWith(
                      color: AppColors.primary,
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                  const SizedBox(height: 4),
                  Text(
                    'درع الأمان',
                    style: AppTypography.headlineLg.copyWith(
                      color: AppColors.secondary,
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 280,
                    child: Text(
                      'أمن متقدم مدعوم بالذكاء الاصطناعي لنظامك الرقمي. يقظ، استباقي، ولا ينكسر.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: _SplashTactileButton(
                      onPressed: () => context.go('/auth'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'مشفر ببروتوكولات ذكاء اصطناعي 256 بت',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 10,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashTactileButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _SplashTactileButton({required this.onPressed});

  @override
  State<_SplashTactileButton> createState() => _SplashTactileButtonState();
}

class _SplashTactileButtonState extends State<_SplashTactileButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.onPrimaryFixedVariant,
              offset: Offset(0, _pressed ? 2 : 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ابدأ الآن',
              style: AppTypography.headlineLg.copyWith(
                color: AppColors.onPrimaryFixed,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back, color: AppColors.onPrimaryFixed),
          ],
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    const spacing = 24.0;
    const dotRadius = 0.5;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
