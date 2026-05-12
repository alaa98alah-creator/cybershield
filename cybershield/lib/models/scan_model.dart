enum ScanType { file, link }

enum ScanStatus { pending, scanning, completed, failed }

class ScanModel {
  final String scanId;
  final String userId;
  final ScanType scanType;
  final String targetValue;
  final ScanStatus status;
  final DateTime createdAt;

  const ScanModel({
    required this.scanId,
    required this.userId,
    required this.scanType,
    required this.targetValue,
    required this.status,
    required this.createdAt,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      scanId: json['scan_id'] as String,
      userId: json['user_id'] as String,
      scanType: ScanType.values.firstWhere(
        (e) => e.name == (json['scan_type'] as String).toLowerCase(),
      ),
      targetValue: json['target_value'] as String,
      status: ScanStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String).toLowerCase(),
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scan_id': scanId,
      'user_id': userId,
      'scan_type': scanType.name,
      'target_value': targetValue,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ScanModel copyWith({ScanStatus? status}) {
    return ScanModel(
      scanId: scanId,
      userId: userId,
      scanType: scanType,
      targetValue: targetValue,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
