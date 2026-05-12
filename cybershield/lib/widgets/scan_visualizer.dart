import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScanVisualizer extends StatelessWidget {
  final double size;
  final bool showLabel;
  final IconData centerIcon;
  final String? label;

  const ScanVisualizer({
    super.key,
    this.size = 192,
    this.showLabel = true,
    this.centerIcon = Icons.shield,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    width: 4,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.0, 1.0),
              ),

          Container(
            width: size - 32,
            height: size - 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

          Container(
            width: size - 64,
            height: size - 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
          ).animate().fadeIn(duration: 1000.ms, delay: 400.ms),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                centerIcon,
                color: AppColors.primary,
                size: size * 0.25,
                fill: 1.0,
              ),
              if (showLabel) ...[
                const SizedBox(height: 8),
                Text(
                  label ?? 'الذكاء الاصطناعي نشط',
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
