class VtResultModel {
  final String vtResultId;
  final String scanId;
  final int maliciousCount;
  final int suspiciousCount;
  final int harmlessCount;
  final int undetectedCount;
  final String vtPermalink;
  final Map<String, dynamic> rawJsonData;

  const VtResultModel({
    required this.vtResultId,
    required this.scanId,
    required this.maliciousCount,
    required this.suspiciousCount,
    required this.harmlessCount,
    required this.undetectedCount,
    required this.vtPermalink,
    required this.rawJsonData,
  });

  factory VtResultModel.fromJson(Map<String, dynamic> json) {
    return VtResultModel(
      vtResultId: json['vt_result_id'] as String,
      scanId: json['scan_id'] as String,
      maliciousCount: json['malicious_count'] as int,
      suspiciousCount: json['suspicious_count'] as int,
      harmlessCount: json['harmless_count'] as int,
      undetectedCount: json['undetected_count'] as int,
      vtPermalink: json['vt_permalink'] as String,
      rawJsonData: json['raw_json_data'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vt_result_id': vtResultId,
      'scan_id': scanId,
      'malicious_count': maliciousCount,
      'suspicious_count': suspiciousCount,
      'harmless_count': harmlessCount,
      'undetected_count': undetectedCount,
      'vt_permalink': vtPermalink,
      'raw_json_data': rawJsonData,
    };
  }

  int get totalEngines =>
      maliciousCount + suspiciousCount + harmlessCount + undetectedCount;
}
