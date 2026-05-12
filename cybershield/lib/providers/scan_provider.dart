import 'package:cybershield/models/ai_analysis_model.dart';
import 'package:cybershield/models/scan_model.dart';
import 'package:cybershield/models/vt_result_model.dart';
import 'package:cybershield/services/scan_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ScanUiState { idle, scanning, polling, completed, error }

class ScanState {
  final ScanUiState uiState;
  final String? scanId;
  final ScanModel? scan;
  final VtResultModel? vtResult;
  final AiAnalysisModel? aiAnalysis;
  final String? error;
  final double progress;

  const ScanState({
    this.uiState = ScanUiState.idle,
    this.scanId,
    this.scan,
    this.vtResult,
    this.aiAnalysis,
    this.error,
    this.progress = 0.0,
  });

  ScanState copyWith({
    ScanUiState? uiState,
    String? scanId,
    ScanModel? scan,
    VtResultModel? vtResult,
    AiAnalysisModel? aiAnalysis,
    String? error,
    double? progress,
  }) {
    return ScanState(
      uiState: uiState ?? this.uiState,
      scanId: scanId ?? this.scanId,
      scan: scan ?? this.scan,
      vtResult: vtResult ?? this.vtResult,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      error: error,
      progress: progress ?? this.progress,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier() : super(const ScanState());

  final _scanService = ScanService.instance;

  Future<void> scanLink(String url) async {
    state = state.copyWith(uiState: ScanUiState.scanning, progress: 0.1);
    try {
      final scanId = await _scanService.scanLink(url);
      state = state.copyWith(
        scanId: scanId,
        uiState: ScanUiState.polling,
        progress: 0.3,
      );
      await _pollResults(scanId);
    } on DioException catch (e) {
      state = state.copyWith(
        uiState: ScanUiState.error,
        error: e.response?.data?['message'] as String? ?? 'فشل فحص الرابط',
      );
    } catch (e) {
      state = state.copyWith(
        uiState: ScanUiState.error,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  Future<void> scanFile(String filePath, String fileName) async {
    state = state.copyWith(uiState: ScanUiState.scanning, progress: 0.1);
    try {
      final scanId = await _scanService.scanFile(filePath, fileName);
      state = state.copyWith(
        scanId: scanId,
        uiState: ScanUiState.polling,
        progress: 0.3,
      );
      await _pollResults(scanId);
    } on DioException catch (e) {
      state = state.copyWith(
        uiState: ScanUiState.error,
        error: e.response?.data?['message'] as String? ?? 'فشل فحص الملف',
      );
    } catch (e) {
      state = state.copyWith(
        uiState: ScanUiState.error,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  Future<void> _pollResults(String scanId) async {
    final result = await _scanService.pollScanResult(scanId);
    if (result != null) {
      final scan = ScanModel.fromJson(result.scan);
      final vtResult = result.vtResult != null
          ? VtResultModel.fromJson(result.vtResult!)
          : null;
      final aiAnalysis = result.aiAnalysis != null
          ? AiAnalysisModel.fromJson(result.aiAnalysis!)
          : null;
      state = state.copyWith(
        uiState: ScanUiState.completed,
        scan: scan,
        vtResult: vtResult,
        aiAnalysis: aiAnalysis,
        progress: 1.0,
      );
    } else {
      state = state.copyWith(
        uiState: ScanUiState.error,
        error: 'انتهت مهلة الانتظار',
      );
    }
  }

  void reset() {
    state = const ScanState();
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>(
  (ref) => ScanNotifier(),
);
