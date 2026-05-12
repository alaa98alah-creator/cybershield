enum RiskLevel { safe, low, medium, high, critical }

class AiAnalysisModel {
  final String aiAnalysisId;
  final String scanId;
  final RiskLevel riskLevel;
  final String simplifiedSummary;
  final List<String> preventiveTips;
  final DateTime generatedAt;

  const AiAnalysisModel({
    required this.aiAnalysisId,
    required this.scanId,
    required this.riskLevel,
    required this.simplifiedSummary,
    required this.preventiveTips,
    required this.generatedAt,
  });

  factory AiAnalysisModel.fromJson(Map<String, dynamic> json) {
    return AiAnalysisModel(
      aiAnalysisId: json['ai_analysis_id'] as String,
      scanId: json['scan_id'] as String,
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == (json['risk_level'] as String).toLowerCase(),
      ),
      simplifiedSummary: json['simplified_summary'] as String,
      preventiveTips: List<String>.from(json['preventive_tips'] as List? ?? []),
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ai_analysis_id': aiAnalysisId,
      'scan_id': scanId,
      'risk_level': riskLevel.name,
      'simplified_summary': simplifiedSummary,
      'preventive_tips': preventiveTips,
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  bool get isSafe => riskLevel == RiskLevel.safe || riskLevel == RiskLevel.low;
  bool get isThreat =>
      riskLevel == RiskLevel.high || riskLevel == RiskLevel.critical;
  bool get isSuspicious => riskLevel == RiskLevel.medium;
}
