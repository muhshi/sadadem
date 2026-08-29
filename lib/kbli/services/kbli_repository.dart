import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:Dalem/kbli/models/kbli_item.dart';
import 'package:Dalem/kbli/models/kbli_hierarchy_item.dart';
import 'package:Dalem/kbli/models/kbli_submission.dart';
import 'package:Dalem/kbli/services/kbli_api_service.dart';
import 'package:Dalem/kbli/services/kbli_local_db_service.dart';

class KbliSearchResult {
  final List<KbliItem> items;
  final bool isOnline;
  final String? message;

  KbliSearchResult({
    required this.items,
    required this.isOnline,
    this.message,
  });
}

class KbliRepository {
  final KbliApiService _apiService;

  KbliRepository({KbliApiService? apiService})
      : _apiService = apiService ?? KbliApiService();

  /// Check whether device has network connection.
  Future<bool> isNetworkConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.any((result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn);
    } catch (_) {
      return false;
    }
  }

  /// Smart Search with auto-fallback between Online AI/REST and Local SQLite FTS5.
  Future<KbliSearchResult> search(
    String query, {
    String? type,
    int limit = 20,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return KbliSearchResult(items: [], isOnline: true);
    }

    final isOnline = await isNetworkConnected();

    // 1. Try Online Search first if connected
    if (isOnline) {
      try {
        final onlineResults = await _apiService.search(
          cleanQuery,
          type: type,
          limit: limit,
        );
        if (onlineResults.isNotEmpty) {
          return KbliSearchResult(items: onlineResults, isOnline: true);
        }
      } catch (e) {
        debugPrint('Online KBLI search failed, falling back to local DB: $e');
      }
    }

    // 2. Fallback to Local SQLite FTS5 Search
    final offlineResults = await KbliLocalDbService.searchFts(
      cleanQuery,
      type: type,
      limit: limit,
    );

    final isDbReady = await KbliLocalDbService.isDatabaseReady();
    String? fallbackMessage;
    if (!isDbReady) {
      fallbackMessage =
          'Database offline belum diunduh. Hubungkan internet untuk mencari online atau unduh data di menu Sinkronisasi.';
    } else if (offlineResults.isEmpty && !isOnline) {
      fallbackMessage =
          'Tidak ditemukan hasil di database offline. Coba kata kunci lain atau periksa koneksi internet.';
    }

    return KbliSearchResult(
      items: offlineResults,
      isOnline: false,
      message: fallbackMessage,
    );
  }

  /// Get Hierarchy Tree Items.
  Future<List<KbliHierarchyItem>> getHierarchy({String? parent}) async {
    return await _apiService.getHierarchy(parent: parent);
  }

  /// Check sync bundle info from server.
  Future<Map<String, dynamic>?> checkSyncInfo() async {
    return await _apiService.checkSync();
  }

  /// Download and install offline database bundle.
  Future<bool> syncOfflineBundle({
    required String tempSavePath,
    required String targetVersion,
    void Function(int count, int total)? onProgress,
  }) async {
    final downloaded = await _apiService.downloadBundle(
      savePath: tempSavePath,
      onReceiveProgress: onProgress,
    );

    if (downloaded) {
      return await KbliLocalDbService.installBundle(
        downloadedFilePath: tempSavePath,
        version: targetVersion,
      );
    }
    return false;
  }

  /// Submit crowdsourcing example (Online or Offline Queue).
  Future<bool> submitExample(KbliSubmission submission) async {
    final isOnline = await isNetworkConnected();

    if (isOnline) {
      try {
        await _apiService.submitSingle(submission);
        // Save to local history as synced
        await KbliLocalDbService.saveLocalSubmission(
          submission.copyWith(status: 'synced', isSynced: true),
        );
        return true;
      } catch (e) {
        debugPrint('Online submission failed, saving to offline queue: $e');
      }
    }

    // Save to offline queue
    await KbliLocalDbService.saveLocalSubmission(
      submission.copyWith(status: 'pending', isSynced: false),
    );
    return false; // Stored offline
  }

  /// Bulk sync pending offline submissions when back online.
  Future<int> syncPendingSubmissions() async {
    final isOnline = await isNetworkConnected();
    if (!isOnline) return 0;

    final pending = await KbliLocalDbService.getPendingSubmissions();
    if (pending.isEmpty) return 0;

    try {
      final syncedCount = await _apiService.bulkSync(pending);
      if (syncedCount > 0) {
        final idsToMark = pending.map((s) => s.id!).whereType<int>().toList();
        await KbliLocalDbService.markSubmissionsSynced(idsToMark);
      }
      return syncedCount;
    } catch (e) {
      debugPrint('Error bulk syncing pending submissions: $e');
      return 0;
    }
  }
}
