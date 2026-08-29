import 'package:dio/dio.dart';
import 'package:Dalem/config/api_config.dart';
import 'package:Dalem/kbli/models/kbli_item.dart';
import 'package:Dalem/kbli/models/kbli_hierarchy_item.dart';
import 'package:Dalem/kbli/models/kbli_submission.dart';

class KbliApiService {
  final Dio _dio;

  KbliApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.kbliBaseUrl,
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 8),
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  /// Fast online search on KBLI 2025 & KBJI 2014 (`GET /search`).
  Future<List<KbliItem>> search(
    String query, {
    String? type,
    int limit = 20,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final response = await _dio.get(
      '/search',
      queryParameters: {
        'q': cleanQuery,
        if (type != null && type.isNotEmpty && type != 'ALL') 'type': type,
        'limit': limit,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map && data['status'] == 'success') {
        final results = data['data']?['results'];
        if (results is List) {
          return results
              .map((item) => KbliItem.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    }
    return [];
  }

  /// Explore KBLI Tree Hierarchy (`GET /kbli/hierarchy`).
  Future<List<KbliHierarchyItem>> getHierarchy({String? parent}) async {
    final response = await _dio.get(
      '/kbli/hierarchy',
      queryParameters: {
        if (parent != null && parent.isNotEmpty) 'parent': parent,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map && data['status'] == 'success') {
        final list = data['data'];
        if (list is List) {
          return list
              .map((item) =>
                  KbliHierarchyItem.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    }
    return [];
  }

  /// Check latest offline bundle version & checksum (`GET /sync/check`).
  Future<Map<String, dynamic>?> checkSync() async {
    final response = await _dio.get('/sync/check');
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map && data['status'] == 'success') {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
    }
    return null;
  }

  /// Download the offline SQLite database bundle (`GET /sync/bundle`).
  Future<bool> downloadBundle({
    required String savePath,
    void Function(int count, int total)? onReceiveProgress,
  }) async {
    final response = await _dio.download(
      '/sync/bundle',
      savePath,
      onReceiveProgress: onReceiveProgress,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
    );
    return response.statusCode == 200;
  }

  /// Submit a single crowdsourcing example (`POST /submissions`).
  Future<Map<String, dynamic>> submitSingle(KbliSubmission submission) async {
    final response = await _dio.post(
      '/submissions',
      data: submission.toServerJson(),
    );

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null) {
      final data = response.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    }
    throw Exception('Gagal mengirim pengajuan (${response.statusCode})');
  }

  /// Bulk sync offline submissions when back online (`POST /submissions/bulk-sync`).
  Future<int> bulkSync(List<KbliSubmission> submissions) async {
    if (submissions.isEmpty) return 0;

    final body = {
      'submissions': submissions.map((s) => s.toServerJson()).toList(),
    };

    final response = await _dio.post(
      '/submissions/bulk-sync',
      data: body,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map && data['status'] == 'success') {
        final syncedCount = data['data']?['synced_count'];
        if (syncedCount is num) {
          return syncedCount.toInt();
        }
        return submissions.length;
      }
    }
    return 0;
  }
}
