import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:cybershield/providers/scan_provider.dart';
import 'package:cybershield/widgets/cyber_bottom_nav.dart';
import 'package:cybershield/widgets/cyber_top_bar.dart';
import 'package:cybershield/widgets/scan_visualizer.dart';
import 'package:cybershield/widgets/tactile_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LinkScannerScreen extends ConsumerStatefulWidget {
  const LinkScannerScreen({super.key});

  @override
  ConsumerState<LinkScannerScreen> createState() => _LinkScannerScreenState();
}

class _LinkScannerScreenState extends ConsumerState<LinkScannerScreen> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إدخال رابط')));
      return;
    }
    ref.read(scanProvider.notifier).scanLink(url);
    context.push('/analyzing');
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _urlController.text = data!.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CyberTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: 100,
              ),
              child: Column(
                children: [
                  const Center(
                    child: ScanVisualizer(
                      size: 280,
                      centerIcon: Icons.security,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'فاحص الروابط',
                    style: AppTypography.headlineXl.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اكتشف الروابط الخبيثة ومحاولات التصيد قبل أن تضر بجهازك.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: TextField(
                        controller: _urlController,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'الصق الرابط هنا...',
                          hintStyle: AppTypography.bodyMd.copyWith(
                            color: AppColors.outline,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(right: 12, left: 12),
                            child: Icon(Icons.link, color: AppColors.outline),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextButton(
                              onPressed: _pasteFromClipboard,
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.secondaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              child: Text(
                                'لصق',
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _InfoBadge(label: 'HTTPS فقط'),
                          const SizedBox(width: 8),
                          _InfoBadge(label: 'وقت حقيقي'),
                        ],
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
                        icon: const Icon(Icons.language, size: 14),
                        label: const Text('English'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TactileButton(
                    label: 'بدأ الفحص',
                    onPressed: _startScan,
                    icon: Icons.radar,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'نحن نفحص البصمة الرقمية فقط لحماية خصوصيتك. بياناتك تبقى مشفرة ومجهولة.',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'نتائج حديثة',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.outline,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning, color: AppColors.error),
                              const SizedBox(height: 8),
                              Text(
                                'تم فحص 3',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'آخر 24 ساعة',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.outline,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.verified,
                                color: AppColors.primary,
                                fill: 1.0,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'بيئة آمنة',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'لم يتم اكتشاف تهديدات',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.onPrimaryContainer
                                      .withValues(alpha: 0.7),
                                  fontSize: 10,
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

class _InfoBadge extends StatelessWidget {
  final String label;

  const _InfoBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.05,
        ),
      ),
    );
  }
}
