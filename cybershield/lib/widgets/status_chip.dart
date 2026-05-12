import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:cybershield/models/ai_analysis_model.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final RiskLevel riskLevel;
  final double? dotSize;

  const StatusChip({super.key, required this.riskLevel, this.dotSize});

  @override
  Widget build(BuildContext context) {
    final config = _chipConfig;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize ?? 8,
            height: dotSize ?? 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: config.dotColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: AppTypography.labelSm.copyWith(
              fontSize: 10,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _ChipConfig get _chipConfig {
    switch (riskLevel) {
      case RiskLevel.safe:
      case RiskLevel.low:
        return _ChipConfig(
          label: 'آمن',
          dotColor: AppColors.safe,
          backgroundColor: AppColors.safeContainer,
          textColor: const Color(0xFF4ADE80),
        );
      case RiskLevel.medium:
        return _ChipConfig(
          label: 'مشبوه',
          dotColor: AppColors.suspicious,
          backgroundColor: AppColors.suspiciousContainer,
          textColor: const Color(0xFFFACC15),
        );
      case RiskLevel.high:
      case RiskLevel.critical:
        return _ChipConfig(
          label: 'خبيث',
          dotColor: AppColors.error,
          backgroundColor: AppColors.errorContainer,
          textColor: const Color(0xFFFCA5A5),
        );
    }
  }
}

class _ChipConfig {
  final String label;
  final Color dotColor;
  final Color backgroundColor;
  final Color textColor;

  const _ChipConfig({
    required this.label,
    required this.dotColor,
    required this.backgroundColor,
    required this.textColor,
  });
}
