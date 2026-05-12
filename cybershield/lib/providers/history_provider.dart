import 'package:cybershield/models/scan_model.dart';
import 'package:cybershield/services/scan_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryState {
  final List<ScanModel> scans;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const HistoryState({
    this.scans = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  HistoryState copyWith({
    List<ScanModel>? scans,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return HistoryState(
      scans: scans ?? this.scans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<ScanModel> get filteredScans {
    if (searchQuery.isEmpty) return scans;
    return scans
        .where(
          (s) =>
              s.targetValue.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(const HistoryState());

  final _scanService = ScanService.instance;

  Future<void> fetchHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final scans = await _scanService.getHistory();
      state = state.copyWith(scans: scans, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] as String? ?? 'فشل تحميل السجل',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'حدث خطأ غير متوقع');
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>(
  (ref) => HistoryNotifier()..fetchHistory(),
);
