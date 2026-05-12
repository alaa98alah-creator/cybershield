import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:cybershield/models/ai_analysis_model.dart';
import 'package:cybershield/models/scan_model.dart';
import 'package:cybershield/widgets/cyber_bottom_nav.dart';
import 'package:cybershield/widgets/cyber_top_bar.dart';
import 'package:cybershield/widgets/scan_list_item.dart';
import 'package:cybershield/widgets/scan_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    'مرحباً بك',
                    style: AppTypography.headlineXl.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.verified_user,
                          color: AppColors.primary,
                          size: 18,
                          fill: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'جهازك آمن',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Center(child: ScanVisualizer(size: 192)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.link,
                          title: 'فحص رابط',
                          subtitle: 'تحقق من الروابط',
                          backgroundColor: AppColors.primaryContainer,
                          iconColor: AppColors.primary,
                          shadowColor: const Color(0xFF2C0050),
                          onTap: () => context.push('/link-scanner'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.upload_file,
                          title: 'فحص ملف',
                          subtitle: 'تحميل المستندات',
                          backgroundColor: AppColors.tertiaryContainer,
                          iconColor: AppColors.tertiary,
                          shadowColor: const Color(0xFF2A064B),
                          onTap: () => context.push('/file-scanner'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'عمليات الفحص الأخيرة',
                        style: AppTypography.headlineLg.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/history'),
                        child: Text(
                          'عرض الكل',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ScanListItem(
                    scan: ScanModel(
                      scanId: '1',
                      userId: 'u1',
                      scanType: ScanType.file,
                      targetValue: 'invoice_2024.pdf',
                      status: ScanStatus.completed,
                      createdAt: DateTime.now().subtract(
                        const Duration(minutes: 2),
                      ),
                    ),
                    riskLevel: RiskLevel.safe,
                  ),
                  const SizedBox(height: 8),
                  ScanListItem(
                    scan: ScanModel(
                      scanId: '2',
                      userId: 'u1',
                      scanType: ScanType.link,
                      targetValue: 'bit.ly/secure-login',
                      status: ScanStatus.completed,
                      createdAt: DateTime.now().subtract(
                        const Duration(hours: 1),
                      ),
                    ),
                    riskLevel: RiskLevel.critical,
                  ),
                  const SizedBox(height: 8),
                  ScanListItem(
                    scan: ScanModel(
                      scanId: '3',
                      userId: 'u1',
                      scanType: ScanType.file,
                      targetValue: 'photo_archive.zip',
                      status: ScanStatus.completed,
                      createdAt: DateTime.now().subtract(
                        const Duration(hours: 3),
                      ),
                    ),
                    riskLevel: RiskLevel.safe,
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

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconColor;
  final Color shadowColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconColor,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        height: 160,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              offset: Offset(0, _pressed ? 2 : 4),
              blurRadius: 0,
            ),
          ],
          border: const Border(top: BorderSide(color: Color(0x1AFFFFFF))),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: AppTypography.bodyLg.copyWith(
                color: widget.iconColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: AppTypography.labelSm.copyWith(
                color: widget.iconColor.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
