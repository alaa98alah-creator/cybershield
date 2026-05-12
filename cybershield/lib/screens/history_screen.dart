import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:cybershield/models/scan_model.dart';
import 'package:cybershield/providers/history_provider.dart';
import 'package:cybershield/widgets/cyber_bottom_nav.dart';
import 'package:cybershield/widgets/cyber_top_bar.dart';
import 'package:cybershield/widgets/tactile_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final scans = historyState.filteredScans;
    final hasThreats = scans.any((s) => s.status == ScanStatus.completed);

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
                  _SearchField(
                    controller: _searchController,
                    onChanged: (query) =>
                        ref.read(historyProvider.notifier).search(query),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سجل الفحص',
                            style: AppTypography.headlineLg.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'نشاطك خلال آخر 30 يوماً',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'تصفية',
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.filter_list,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (historyState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (historyState.error != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Text(
                          historyState.error!,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (scans.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Text(
                          'لا توجد عمليات فحص',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    ...scans.map(
                      (scan) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _HistoryItem(scan: scan),
                      ),
                    ),
                  ],
                  if (hasThreats) ...[
                    const SizedBox(height: 16),
                    _ThreatBanner(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CyberBottomNav(currentIndex: 1),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant, width: 2),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: 'البحث في سجل الفحوصات...',
          hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 12),
            child: Icon(Icons.search, color: AppColors.outline, size: 24),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryContainer,
              width: 2,
            ),
          ),
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final ScanModel scan;

  const _HistoryItem({required this.scan});

  Color get _iconBgColor {
    switch (scan.status) {
      case ScanStatus.completed:
        return AppColors.primaryContainer;
      default:
        return AppColors.tertiaryContainer;
    }
  }

  Color get _iconColor {
    switch (scan.scanType) {
      case ScanType.link:
        return AppColors.primary;
      case ScanType.file:
        return AppColors.primary;
    }
  }

  IconData get _icon {
    switch (scan.scanType) {
      case ScanType.link:
        return Icons.link;
      case ScanType.file:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLink = scan.scanType == ScanType.link;

    return GestureDetector(
      onTap: () => context.push('/report?scanId=${scan.scanId}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isLink ? scan.targetValue : scan.targetValue,
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: isLink
                              ? TextDirection.ltr
                              : TextDirection.rtl,
                        ),
                      ),
                      _InlineStatusChip(scan: scan),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(scan.createdAt),
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_left, color: AppColors.outline, size: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month]}، ${date.year} • $hour:$minute';
  }
}

class _InlineStatusChip extends StatelessWidget {
  final ScanModel scan;

  const _InlineStatusChip({required this.scan});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: config.dotColor,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          config.label,
          style: AppTypography.labelSm.copyWith(color: config.textColor),
        ),
      ],
    );
  }

  _StatusConfig get _statusConfig {
    switch (scan.status) {
      case ScanStatus.completed:
        return const _StatusConfig(
          label: 'آمن',
          dotColor: Color(0xFF22C55E),
          textColor: Color(0xFF4ADE80),
        );
      case ScanStatus.failed:
        return const _StatusConfig(
          label: 'خبيث',
          dotColor: AppColors.error,
          textColor: Color(0xFFFCA5A5),
        );
      case ScanStatus.pending:
      case ScanStatus.scanning:
        return const _StatusConfig(
          label: 'مشبوه',
          dotColor: Color(0xFFEAB308),
          textColor: Color(0xFFFACC15),
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color dotColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.dotColor,
    required this.textColor,
  });
}

class _ThreatBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          bottom: BorderSide(color: AppColors.onPrimaryFixed, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.security,
                color: AppColors.onPrimaryContainer,
                size: 80,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هل تحتاج لتنظيف عميق؟',
                style: AppTypography.headlineLg.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'تم رصد عنصرين في السجل مصنفين كعالي الخطورة. هل تود حذفهما نهائياً؟',
                style: AppTypography.bodyMd.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              TactileButton(
                label: 'معالجة كافة التهديدات',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري معالجة التهديدات...')),
                  );
                },
                backgroundColor: Colors.white,
                textColor: AppColors.primaryContainer,
                shadowColor: AppColors.onPrimaryFixedVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
