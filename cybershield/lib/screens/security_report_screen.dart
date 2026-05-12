import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:cybershield/models/ai_analysis_model.dart';
import 'package:cybershield/providers/scan_provider.dart';
import 'package:cybershield/widgets/cyber_bottom_nav.dart';
import 'package:cybershield/widgets/cyber_top_bar.dart';
import 'package:cybershield/widgets/tactile_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecurityReportScreen extends ConsumerWidget {
  final String scanId;

  const SecurityReportScreen({super.key, required this.scanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final aiAnalysis = scanState.aiAnalysis;
    final vtResult = scanState.vtResult;
    final isSafe = aiAnalysis?.isSafe ?? true;
    final isThreat = aiAnalysis?.isThreat ?? false;

    return Scaffold(
      body: Column(
        children: [
          CyberTopBar(showBack: true, useGlassStyle: true),
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
                    'نتيجة فحص الأمان • SECURITY SCAN',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.onTertiaryContainer,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatusCard(isSafe: isSafe, isThreat: isThreat),
                  const SizedBox(height: 16),
                  _AiSummaryCard(aiAnalysis: aiAnalysis),
                  const SizedBox(height: 16),
                  _VtAccordion(vtResult: vtResult),
                  const SizedBox(height: 24),
                  TactileButton(
                    label: 'فتح الرابط بأمان',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لا يمكن فتح الرابط - وضع العرض فقط'),
                        ),
                      );
                    },
                    backgroundColor: AppColors.secondaryContainer,
                    textColor: AppColors.onSecondaryContainer,
                    icon: Icons.open_in_new,
                  ),
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

class _StatusCard extends StatelessWidget {
  final bool isSafe;
  final bool isThreat;

  const _StatusCard({required this.isSafe, required this.isThreat});

  @override
  Widget build(BuildContext context) {
    final statusColor = isSafe
        ? const Color(0xFF10B981)
        : isThreat
        ? AppColors.error
        : AppColors.suspicious;
    final statusLabel = isSafe
        ? 'آمن / Safe'
        : isThreat
        ? 'خبيث / Threat'
        : 'مشبوه / Suspicious';
    final statusDesc = isSafe
        ? 'هذا الرابط آمن تماماً للاستخدام'
        : isThreat
        ? 'تحذير! هذا الرابط يحتوي على تهديدات'
        : 'هذا الرابط يحتوي على عناصر مشبوهة';
    final statusIcon = isSafe ? Icons.check_circle : Icons.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border(right: BorderSide(color: statusColor, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.1),
            ),
            child: Icon(statusIcon, color: statusColor, size: 40, fill: 1.0),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: AppTypography.headlineLg.copyWith(color: statusColor),
                ),
                const SizedBox(height: 4),
                Text(
                  statusDesc,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiSummaryCard extends StatelessWidget {
  final AiAnalysisModel? aiAnalysis;

  const _AiSummaryCard({this.aiAnalysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.onPrimaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smart_toy, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ملخص ذكاء جيمني الاصطناعي',
                  style: AppTypography.headlineLg.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            aiAnalysis?.simplifiedSummary ??
                'يؤكد نظام جيمني أن هذا الرابط يؤدي إلى موقع موثق ولا يحتوي على أي برمجيات ضارة أو أنشطة مشبوهة. يبدو أنها خدمة شرعية وآمنة للبيانات.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0x334C4451)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'نصائح وقائية هامة',
                style: AppTypography.labelMd.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(aiAnalysis?.preventiveTips ??
                  [
                    'تحقق دائماً من اسم النطاق (URL) بحثاً عن أي أخطاء إملائية.',
                    'تجنب النقر على الروابط الواردة في رسائل SMS مجهولة المصدر.',
                    'لا تقم بإدخال بياناتك الحساسة إلا في المواقع التي تثق بها تماماً.',
                  ])
              .map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 8, left: 8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _VtAccordion extends StatefulWidget {
  final dynamic vtResult;

  const _VtAccordion({this.vtResult});

  @override
  State<_VtAccordion> createState() => _VtAccordionState();
}

class _VtAccordionState extends State<_VtAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.security_update_good,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'التفاصيل التقنية (VirusTotal)',
                      style: AppTypography.headlineLg.copyWith(fontSize: 18),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'اكتشافات برمجيات ضارة',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            '${widget.vtResult?.maliciousCount ?? 0} / ${widget.vtResult?.totalEngines ?? 65}',
                            style: AppTypography.labelMd.copyWith(
                              color: const Color(0xFF4ADE80),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'محركات الفحص: Google Safe Browsing، BitDefender، Kaspersky، و 62 محركاً آخر لم تبلغ عن أي تهديدات.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.outline,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
