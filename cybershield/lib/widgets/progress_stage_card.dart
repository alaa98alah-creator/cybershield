import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

enum StageStatus { completed, active, pending }

class ProgressStageCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final StageStatus status;
  final Color accentColor;

  const ProgressStageCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == StageStatus.active;
    final isCompleted = status == StageStatus.completed;
    final isPending = status == StageStatus.pending;

    return AnimatedOpacity(
      opacity: isPending ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.surfaceContainer
              : isActive
              ? AppColors.surfaceContainerHigh
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border(right: BorderSide(color: accentColor, width: 4))
              : isCompleted
              ? Border(right: BorderSide(color: accentColor, width: 4))
              : Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.primaryContainer
                    : isActive
                    ? AppColors.primary
                    : AppColors.surfaceContainerHighest,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.cloud_done,
                        color: AppColors.primary,
                        size: 20,
                      )
                    : isActive
                    ? Icon(icon, color: AppColors.onPrimary, size: 20)
                    : Icon(icon, color: AppColors.outline, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: AppTypography.labelSm.copyWith(
                      color: isCompleted
                          ? AppColors.onPrimaryContainer
                          : isActive
                          ? AppColors.onPrimary
                          : AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.bodyMd.copyWith(
                      color: isPending
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                fill: 1.0,
                size: 24,
              ),
            if (isActive)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: accentColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
