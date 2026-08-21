import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:Dalem/components/offline_storage.dart';

/// Centralized API service with automatic offline cache fallback.
class BpsApiService {
  /// Fetches JSON Object (`Map<String, dynamic>`) from [url].
  /// On success, automatically caches data in [OfflineStorage].
  /// On failure/offline, falls back to cached data if available.
  static Future<Map<String, dynamic>> fetchJson(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 12),
          );
      if (response.statusCode == 200) {
        final jsonResponse =
            json.decode(response.body) as Map<String, dynamic>;
        await OfflineStorage.saveData(url, jsonResponse);
        return jsonResponse;
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Network fetch failed ($url): $e. Trying offline cache...');
      final offlineData = await OfflineStorage.loadData(url);
      if (offlineData != null && offlineData is Map<String, dynamic>) {
        return offlineData;
      }
      rethrow;
    }
  }

  /// Fetches data list from a BPS API list endpoint (usually located at `data['data'][1]`).
  static Future<List<dynamic>> fetchDataList(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 12),
          );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null &&
            jsonResponse['data'] is List &&
            (jsonResponse['data'] as List).length > 1) {
          final listData = jsonResponse['data'][1] as List<dynamic>;
          await OfflineStorage.saveData(url, listData);
          return listData;
        }
        return [];
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint(
          'Network fetch failed ($url): $e. Trying offline cache...');
      final offlineData = await OfflineStorage.loadData(url);
      if (offlineData != null && offlineData is List<dynamic>) {
        return offlineData;
      }
      rethrow;
    }
  }

  /// Manually invalidate cache for a specific [url].
  static Future<void> invalidateCache(String url) async {
    await OfflineStorage.clearData(url);
  }
}
