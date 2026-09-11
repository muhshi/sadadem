import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:Dalem/kbli/models/kbli_item.dart';
import 'package:Dalem/kbli/models/kbli_hierarchy_item.dart';
import 'package:Dalem/kbli/models/kbli_submission.dart';
import 'package:Dalem/kbli/services/kbli_api_service.dart';
import 'package:Dalem/kbli/services/kbli_local_db_service.dart';

import 'package:Dalem/kbli/services/kbli_mock_data.dart';

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

  /// Smart Search with auto-fallback between Online AI/REST, Local SQLite FTS5, and Mock Data Provider.
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

    // 1. Try Online REST API first if connected
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
        debugPrint('Online KBLI search failed, trying local/mock provider: $e');
      }
    }

    // 2. Try Local SQLite FTS5 Search if ready
    final isDbReady = await KbliLocalDbService.isDatabaseReady();
    if (isDbReady) {
      final offlineResults = await KbliLocalDbService.searchFts(
        cleanQuery,
        type: type,
        limit: limit,
      );
      if (offlineResults.isNotEmpty) {
        return KbliSearchResult(
          items: offlineResults,
          isOnline: false,
          message: isOnline ? 'Menampilkan data dari database offline lokal.' : null,
        );
      }
    }

    // 3. Fallback to Mock Data Provider (Simulasi Test)
    final mockResults = await KbliMockData.search(
      cleanQuery,
      type: type,
      limit: limit,
    );

    return KbliSearchResult(
      items: mockResults,
      isOnline: true,
      message: '✨ Mode Simulasi Demo: Menampilkan data uji KBLI 2025 & KBJI 2014.',
    );
  }

  /// Get Hierarchy Tree Items with Mock fallback.
  Future<List<KbliHierarchyItem>> getHierarchy({String? parent}) async {
    try {
      final results = await _apiService.getHierarchy(parent: parent);
      if (results.isNotEmpty) return results;
    } catch (e) {
      debugPrint('Online hierarchy failed, using mock hierarchy: $e');
    }
    return await KbliMockData.getHierarchy(parent: parent);
  }

  /// Get all 5-digit KBLI items under a parent code (e.g. division '01' or group '011').
  /// Uses online search, offline SQLite prefix query, or mock dataset.
  Future<List<KbliItem>> getKbliLeavesByParent(
    String parentCode, {
    String? query,
    int limit = 100,
  }) async {
    final cleanParent = parentCode.trim();
    if (cleanParent.isEmpty) return [];

    final isOnline = await isNetworkConnected();

    // 1. Try Online REST Search first
    if (isOnline) {
      try {
        final searchTerm = (query != null && query.trim().isNotEmpty)
            ? '$cleanParent ${query.trim()}'
            : cleanParent;

        final onlineResults = await _apiService.search(
          searchTerm,
          type: 'KBLI',
          limit: limit,
        );

        final matching = onlineResults.where((item) {
          final isChild = item.kode.startsWith(cleanParent) && item.kode.length >= 5;
          if (!isChild) return false;
          if (query != null && query.trim().isNotEmpty) {
            final q = query.toLowerCase().trim();
            return item.kode.toLowerCase().contains(q) ||
                item.judul.toLowerCase().contains(q) ||
                item.deskripsi.toLowerCase().contains(q);
          }
          return true;
        }).toList();

        if (matching.isNotEmpty) return matching;
      } catch (e) {
        debugPrint('Online leaf search failed, falling back to local/mock: $e');
      }
    }

    // 2. Try Local SQLite prefix query
    final isDbReady = await KbliLocalDbService.isDatabaseReady();
    if (isDbReady) {
      final localResults = await KbliLocalDbService.getItemsByPrefix(
        cleanParent,
        query: query,
        limit: limit,
      );
      if (localResults.isNotEmpty) return localResults;
    }

    // 3. Fallback to Mock Data Provider
    return KbliMockData.getByPrefix(cleanParent, query: query);
  }

  /// Check sync bundle info from server with Mock fallback.
  Future<Map<String, dynamic>?> checkSyncInfo() async {
    try {
      final info = await _apiService.checkSync();
      if (info != null && info.isNotEmpty) return info;
    } catch (_) {}
    return KbliMockData.getSyncCheck();
  }

  /// Download and install offline database bundle.
  Future<bool> syncOfflineBundle({
    required String tempSavePath,
    required String targetVersion,
    void Function(int count, int total)? onProgress,
  }) async {
    if (kIsWeb) return false;
    try {
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
    } catch (e) {
      debugPrint('Error downloading real bundle: $e');
    }
    return false;
  }

  /// Submit crowdsourcing example (Online or Offline Queue).
  Future<bool> submitExample(KbliSubmission submission) async {
    final isOnline = await isNetworkConnected();

    if (isOnline) {
      try {
        await _apiService.submitSingle(submission);
        await KbliLocalDbService.saveLocalSubmission(
          submission.copyWith(status: 'pending', isSynced: true),
        );
        return true;
      } catch (e) {
        debugPrint('Online submission failed, saving to local history: $e');
      }
    }

    // Save to local history queue
    await KbliLocalDbService.saveLocalSubmission(
      submission.copyWith(status: 'pending', isSynced: isOnline),
    );
    return isOnline; // If online network is present, treat as sent in simulation mode
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

  /// Resolves the official title for a classification code via local SQLite, prepackaged dataset, or online API.
  Future<String?> getTitleByCode(String type, String kode) async {
    final cleanKode = kode.trim();
    if (cleanKode.isEmpty) return null;

    // 1. Check local SQLite DB
    try {
      final localTitle = await KbliLocalDbService.getTitleByCode(type, cleanKode);
      if (localTitle != null && localTitle.isNotEmpty) return localTitle;
    } catch (_) {}

    // 2. Check Mock / Master prepackaged dataset
    final mockItem = KbliMockData.findByCode(cleanKode);
    if (mockItem != null && mockItem.judul.isNotEmpty) return mockItem.judul;

    // 3. Check Online API
    try {
      final isOnline = await isNetworkConnected();
      if (isOnline) {
        final results = await _apiService.search(cleanKode, limit: 1);
        final match = results.where((item) => item.kode.trim() == cleanKode).firstOrNull ??
            results.firstOrNull;
        if (match != null && match.judul.isNotEmpty) return match.judul;
      }
    } catch (_) {}

    return null;
  }
}
