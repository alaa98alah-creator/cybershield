import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:cybershield/models/ai_analysis_model.dart';
import 'package:cybershield/models/scan_model.dart';
import 'package:cybershield/widgets/status_chip.dart';
import 'package:flutter/material.dart';

class ScanListItem extends StatelessWidget {
  final ScanModel scan;
  final RiskLevel? riskLevel;
  final VoidCallback? onTap;

  const ScanListItem({
    super.key,
    required this.scan,
    this.riskLevel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLink = scan.scanType == ScanType.link;
    final accentColor = _accentColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border(right: BorderSide(color: accentColor, width: 4)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isLink ? Icons.link : Icons.description,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.targetValue,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(scan.createdAt),
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (riskLevel != null) StatusChip(riskLevel: riskLevel!),
          ],
        ),
      ),
    );
  }

  Color get _accentColor {
    if (riskLevel == null) return AppColors.primary;
    switch (riskLevel!) {
      case RiskLevel.safe:
      case RiskLevel.low:
        return AppColors.safe;
      case RiskLevel.medium:
        return AppColors.suspicious;
      case RiskLevel.high:
      case RiskLevel.critical:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)}, ${date.year}';
  }

  String _monthName(int month) {
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
    return months[month];
  }
}
