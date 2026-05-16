import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:cybershield/providers/scan_provider.dart';
import 'package:cybershield/widgets/cyber_bottom_nav.dart';
import 'package:cybershield/widgets/cyber_top_bar.dart';
import 'package:cybershield/widgets/tactile_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FileScannerScreen extends ConsumerStatefulWidget {
  const FileScannerScreen({super.key});

  @override
  ConsumerState<FileScannerScreen> createState() => _FileScannerScreenState();
}

class _FileScannerScreenState extends ConsumerState<FileScannerScreen> {
  final bool _isDragging = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;

    if (file.path != null) {
      ref.read(scanProvider.notifier).scanFile(file.path!, file.name);
    } else if (file.bytes != null) {
      ref.read(scanProvider.notifier).scanFileBytes(file.bytes!, file.name);
    } else {
      return;
    }
    if (mounted) context.push('/analyzing');
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'فاحص الملفات',
                    style: AppTypography.headlineLg.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'قم بتحميل الملفات للتحقق من البرامج الضارة والتهديدات المحتملة باستخدام محرك الذكاء الاصطناعي الخاص بنا.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _pickFile,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _isDragging
                            ? AppColors.surfaceContainer
                            : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isDragging
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondaryContainer,
                            ),
                            child: const Icon(
                              Icons.cloud_upload,
                              color: AppColors.onSecondaryContainer,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'اسحب وأسقط الملفات هنا',
                            style: AppTypography.headlineLg.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'الحد الأقصى لحجم الملف: 32 ميجابايت. يدعم PDF و ZIP و EXE ومستندات Office.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TactileButton(
                            label: 'تصفح الملفات',
                            onPressed: _pickFile,
                            isFullWidth: false,
                            backgroundColor: AppColors.primaryContainer,
                            textColor: AppColors.onPrimaryContainer,
                            shadowColor: const Color(0xFF2C0050),
                            icon: Icons.folder_open,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.description,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تقرير_أمني_v2.pdf',
                                    style: AppTypography.labelMd.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '1.2 ميجابايت • جاري المعالجة...',
                                    style: AppTypography.bodyMd.copyWith(
                                      color: AppColors.outline,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 0.65,
                            backgroundColor: AppColors.surfaceContainer,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الفحوصات الأخيرة',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.onSurface,
                          letterSpacing: 0.05,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/history'),
                        child: Text(
                          'عرض الكل',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.image, color: AppColors.secondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'فاتورة_مارس.jpg',
                                style: AppTypography.bodyLg.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '450 كيلوبايت • منذ دقيقتين',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.outline,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D3D2E),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF4ADE80),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'آمن',
                                style: AppTypography.labelSm.copyWith(
                                  fontSize: 11,
                                  color: const Color(0xFF4ADE80),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 128,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'إجمالي الملفات المفحوصة',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.onPrimaryContainer
                                      .withValues(alpha: 0.7),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '1,248',
                                style: AppTypography.headlineLg.copyWith(
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 128,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'دقة التهديد بالذكاء الاصطناعي',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.outline,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '99.9%',
                                style: AppTypography.headlineLg.copyWith(
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  4,
                                  (i) => Expanded(
                                    child: Container(
                                      height: 4,
                                      margin: const EdgeInsets.only(left: 2),
                                      decoration: BoxDecoration(
                                        color: i < 3
                                            ? AppColors.primary
                                            : AppColors.primary.withValues(
                                                alpha: 0.3,
                                              ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 192,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.primaryContainer.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'قم بالترقية إلى Pro للفحص الفوري لجميع مرفقات البريد الإلكتروني في السحاب.',
                          textAlign: TextAlign.right,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
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
