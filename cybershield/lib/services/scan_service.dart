import 'package:cybershield/core/constants/api_constants.dart';
import 'package:cybershield/core/constants/app_constants.dart';
import 'package:cybershield/models/ai_analysis_model.dart';
import 'package:cybershield/models/auth_models.dart';
import 'package:cybershield/models/file_metadata_model.dart';
import 'package:cybershield/models/scan_model.dart';
import 'package:cybershield/models/vt_result_model.dart';
import 'package:cybershield/services/network_service.dart';
import 'package:dio/dio.dart';

class ScanService {
  ScanService._();
  static final ScanService instance = ScanService._();
  factory ScanService() => instance;

  final _network = NetworkService();

  Future<String> scanLink(String targetUrl) async {
    try {
      final response = await _network.post(
        ApiConstants.scanLink,
        data: {'target_url': targetUrl},
      );
      return response.data['scan_id'] as String;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<String> scanFile(String filePath, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _network.multipartPost(
        ApiConstants.scanFile,
        formData: formData,
      );
      return response.data['scan_id'] as String;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<String> scanFileBytes(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });
      final response = await _network.multipartPost(
        ApiConstants.scanFile,
        formData: formData,
      );
      return response.data['scan_id'] as String;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<ScanResultResponse> getScanResult(String scanId) async {
    try {
      final response = await _network.get('${ApiConstants.scanResult}/$scanId');
      return ScanResultResponse.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<ScanResultResponse?> pollScanResult(String scanId) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) <
        AppConstants.scanPollTimeout) {
      final result = await getScanResult(scanId);
      final scan = ScanModel.fromJson(result.scan);

      if (scan.status == ScanStatus.completed ||
          scan.status == ScanStatus.failed) {
        return result;
      }

      await Future.delayed(AppConstants.scanPollInterval);
    }
    return null;
  }

  Future<List<ScanModel>> getHistory() async {
    try {
      final response = await _network.get(ApiConstants.scanHistory);
      final List<dynamic> data = response.data as List<dynamic>? ?? [];
      return data
          .map((e) => ScanModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      rethrow;
    }
  }
}

class ScanResultData {
  final ScanModel scan;
  final VtResultModel? vtResult;
  final AiAnalysisModel? aiAnalysis;
  final FileMetadataModel? fileMetadata;

  const ScanResultData({
    required this.scan,
    this.vtResult,
    this.aiAnalysis,
    this.fileMetadata,
  });
}
