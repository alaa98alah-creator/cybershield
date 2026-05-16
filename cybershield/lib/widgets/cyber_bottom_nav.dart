import 'dart:ui';

import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CyberBottomNav extends StatelessWidget {
  final int currentIndex;

  const CyberBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: const Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home,
                    label: 'الرئيسية',
                    isActive: currentIndex == 0,
                    onTap: () => context.go('/home'),
                  ),
                  _NavItem(
                    icon: Icons.history,
                    label: 'السجل',
                    isActive: currentIndex == 1,
                    onTap: () => context.go('/history'),
                  ),
                  _NavItem(
                    icon: Icons.person,
                    label: 'الملف الشخصي',
                    isActive: currentIndex == 2,
                    onTap: () => context.go('/profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 24,
              fill: isActive ? 1.0 : 0.0,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                fontSize: 11,
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
