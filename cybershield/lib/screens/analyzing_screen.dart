// ignore_for_file: use_build_context_synchronously
import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:cybershield/providers/scan_provider.dart';
import 'package:cybershield/widgets/cyber_bottom_nav.dart';
import 'package:cybershield/widgets/cyber_top_bar.dart';
import 'package:cybershield/widgets/progress_stage_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnalyzingScreen extends ConsumerStatefulWidget {
  final String scanId;

  const AnalyzingScreen({super.key, required this.scanId});

  @override
  ConsumerState<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends ConsumerState<AnalyzingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _checkResult());
  }

  void _checkResult() {
    final state = ref.read(scanProvider);
    if (state.uiState == ScanUiState.completed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        context.go('/report?scanId=${widget.scanId}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final progress = scanState.progress;

    ref.listen<ScanState>(scanProvider, (prev, next) {
      if (next.uiState == ScanUiState.completed && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          context.go('/report?scanId=${widget.scanId}');
        });
      }
    });

    return Scaffold(
      body: Column(
        children: [
          const CyberTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  SizedBox(
                    width: 256,
                    height: 256,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 256,
                          height: 256,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              width: 2,
                            ),
                          ),
                        ),
                        Container(
                          width: 224,
                          height: 224,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        Container(
                          width: 192,
                          height: 192,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              width: 2,
                            ),
                          ),
                        ),
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Stack(
                            children: [
                              const _ScanLineAnimation(),
                              Center(
                                child: Icon(
                                  Icons.security,
                                  color: AppColors.primary,
                                  size: 80,
                                  fill: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary,
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.verified_user,
                                  color: AppColors.onPrimary,
                                  size: 18,
                                ),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat())
                            .fadeIn(duration: 600.ms)
                            .then()
                            .fadeOut(duration: 600.ms),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryContainer,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryContainer,
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'تحليل النظام',
                    style: AppTypography.headlineLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يقوم جوهر الذكاء الاصطناعي لدينا بتشريح التهديدات المحتملة عبر طبقات أمنية متعددة.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ProgressStageCard(
                    title: 'طبقة الشبكة',
                    description: 'تجاوز حماية Cloudflare...',
                    icon: Icons.cloud_done,
                    status: progress > 0.2
                        ? StageStatus.completed
                        : StageStatus.pending,
                  ),
                  const SizedBox(height: 8),
                  ProgressStageCard(
                    title: 'مطابقة التوقيع',
                    description: 'جاري التحليل عبر VirusTotal...',
                    icon: Icons.biotech,
                    status: progress > 0.6
                        ? StageStatus.completed
                        : progress > 0.2
                        ? StageStatus.active
                        : StageStatus.pending,
                  ),
                  const SizedBox(height: 8),
                  ProgressStageCard(
                    title: 'ذكاء اصطناعي',
                    description:
                        'يقوم الذكاء الاصطناعي (Gemini) بتوليد التقرير...',
                    icon: Icons.auto_awesome,
                    status: progress > 0.6
                        ? StageStatus.active
                        : StageStatus.pending,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مستوى التهديد',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'منخفض',
                                    style: AppTypography.headlineLg.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الملفات المفحوصة',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '12,482',
                                style: AppTypography.headlineLg.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CyberBottomNav(currentIndex: 0),
    );
  }
}

class _ScanLineAnimation extends StatefulWidget {
  const _ScanLineAnimation();

  @override
  State<_ScanLineAnimation> createState() => _ScanLineAnimationState();
}

class _ScanLineAnimationState extends State<_ScanLineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _controller.value * 160,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary.withValues(
                    alpha: _controller.value < 0.1 || _controller.value > 0.9
                        ? 0.0
                        : 1.0,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
