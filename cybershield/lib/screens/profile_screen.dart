import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:cybershield/providers/auth_provider.dart';
import 'package:cybershield/services/token_storage.dart';
import 'package:cybershield/widgets/cyber_bottom_nav.dart';
import 'package:cybershield/widgets/cyber_top_bar.dart';
import 'package:cybershield/widgets/tactile_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _email;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final tokenStorage = TokenStorage();
    final email = await tokenStorage.getEmail();
    final userId = await tokenStorage.getUserId();
    if (mounted) {
      setState(() {
        _email = email;
        _userId = userId;
      });
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(email: _email, userId: _userId),
                  const SizedBox(height: 24),
                  _ProfileStatsCard(),
                  const SizedBox(height: 24),
                  Text(
                    'الإعدادات',
                    style: AppTypography.headlineLg.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SettingsSection(),
                  const SizedBox(height: 32),
                  TactileButton(
                    label: 'تسجيل الخروج',
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/auth');
                      }
                    },
                    backgroundColor: AppColors.errorContainer,
                    textColor: AppColors.onErrorContainer,
                    shadowColor: AppColors.error,
                    icon: Icons.logout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CyberBottomNav(currentIndex: 2),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String? email;
  final String? userId;

  const _ProfileHeader({this.email, this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          bottom: BorderSide(color: AppColors.onPrimaryFixed, width: 4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.onPrimaryFixedVariant,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Center(
              child: Text(
                _getInitials(),
                style: AppTypography.headlineXl.copyWith(
                  color: AppColors.primary,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مستخدم CyberShield',
                  style: AppTypography.headlineLg.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  email ?? 'user@email.com',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.primary,
                  ),
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.safe.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.safe,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'نشط',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.safe,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    return 'م أ';
  }
}

class _ProfileStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.link,
              label: 'روابط مُفحوصة',
              value: '0',
              color: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 48, color: AppColors.outlineVariant),
          Expanded(
            child: _StatItem(
              icon: Icons.description,
              label: 'ملفات مُفحوصة',
              value: '0',
              color: AppColors.tertiary,
            ),
          ),
          Container(width: 1, height: 48, color: AppColors.outlineVariant),
          Expanded(
            child: _StatItem(
              icon: Icons.shield,
              label: 'تهديدات محظورة',
              value: '0',
              color: AppColors.safe,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.headlineLg.copyWith(
            color: AppColors.onSurface,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsItem(
          icon: Icons.notifications_outlined,
          label: 'الإشعارات',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('الإشعارات قيد التطوير')),
            );
          },
        ),
        const SizedBox(height: 8),
        _SettingsItem(
          icon: Icons.lock_outline,
          label: 'الخصوصية والأمان',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('الخصوصية والأمان قيد التطوير')),
            );
          },
        ),
        const SizedBox(height: 8),
        _SettingsItem(
          icon: Icons.language,
          label: 'اللغة',
          trailing: Text(
            'العربية',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('اللغة قيد التطوير')));
          },
        ),
        const SizedBox(height: 8),
        _SettingsItem(
          icon: Icons.help_outline,
          label: 'المساعدة والدعم',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('المساعدة والدعم قيد التطوير')),
            );
          },
        ),
        const SizedBox(height: 8),
        _SettingsItem(
          icon: Icons.info_outline,
          label: 'حول التطبيق',
          trailing: Text(
            'v1.0.0',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'CyberShield',
              applicationVersion: '1.0.0',
              children: [
                Text(
                  'تطبيق لحماية جهازك من الروابط والملفات الخبيثة',
                  style: AppTypography.bodyMd,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else
              const Icon(
                Icons.chevron_left,
                color: AppColors.outline,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
