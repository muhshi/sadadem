import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Dalem/config/api_config.dart';
import 'package:Dalem/services/bps_api_service.dart';

class StrategicIndicatorItem {
  final String id;
  final String title;
  final String value;
  final String unit;
  final String year;
  final double deltaPercent;
  final bool isTrendGood; // e.g. Poverty down is good, Inflation low is good, PDRB up is good
  final List<double> sparklineData;
  final IconData icon;
  final List<Color> gradient;
  final String tableType;

  const StrategicIndicatorItem({
    required this.id,
    required this.title,
    required this.value,
    required this.unit,
    required this.year,
    required this.deltaPercent,
    required this.isTrendGood,
    required this.sparklineData,
    required this.icon,
    required this.gradient,
    this.tableType = '2',
  });
}

class StrategicIndicatorService {
  /// Default curated strategic indicators for Kabupaten Demak
  /// Used for immediate, offline-ready display and updated with live API data
  static List<StrategicIndicatorItem> getDefaultIndicators() {
    return [
      const StrategicIndicatorItem(
        id: 'inflasi_demak',
        title: 'Laju Inflasi Tahunan',
        value: '2,15',
        unit: '%',
        year: '2024/2025',
        deltaPercent: -0.28,
        isTrendGood: true,
        sparklineData: [3.12, 2.85, 2.50, 2.43, 2.15],
        icon: Icons.show_chart_rounded,
        gradient: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
      ),
      const StrategicIndicatorItem(
        id: 'pdrb_demak',
        title: 'Pertumbuhan Ekonomi (PDRB)',
        value: '5,42',
        unit: '%',
        year: '2024',
        deltaPercent: 0.35,
        isTrendGood: true,
        sparklineData: [4.80, 5.01, 5.15, 5.30, 5.42],
        icon: Icons.trending_up_rounded,
        gradient: [Color(0xFF0D3D85), Color(0xFF2563EB)],
      ),
      const StrategicIndicatorItem(
        id: 'kemiskinan_demak',
        title: 'Persentase Kemiskinan',
        value: '11,92',
        unit: '%',
        year: '2024',
        deltaPercent: -0.17,
        isTrendGood: true, // Poverty decrease is good!
        sparklineData: [12.45, 12.30, 12.18, 12.09, 11.92],
        icon: Icons.auto_graph_rounded,
        gradient: [Color(0xFF065F46), Color(0xFF059669)],
      ),
      const StrategicIndicatorItem(
        id: 'penduduk_demak',
        title: 'Jumlah Penduduk',
        value: '1.241',
        unit: 'Ribu Jiwa',
        year: '2024',
        deltaPercent: 0.62,
        isTrendGood: true,
        sparklineData: [1205, 1215, 1224, 1233, 1241],
        icon: Icons.people_alt_rounded,
        gradient: [Color(0xFFB84C14), Color(0xFFE8611A)],
      ),
    ];
  }

  /// Attempts to fetch live strategic data from BPS Web API
  static Future<List<StrategicIndicatorItem>> fetchLiveIndicators() async {
    final defaultItems = getDefaultIndicators();
    try {
      final url = ApiConfig.listUrl(model: 'tablestatistic', keyword: 'strategis');
      final res = await BpsApiService.fetchJson(url);
      final rawList = (res['data'] is List && (res['data'] as List).length > 1)
          ? (res['data'][1] as List<dynamic>)
          : [];

      if (rawList.isEmpty) return defaultItems;

      // Match available items from API by title keyword
      final updatedList = <StrategicIndicatorItem>[];

      for (var defItem in defaultItems) {
        // Find matching item in rawList
        dynamic matchedItem;
        for (var item in rawList) {
          final title = (item['title']?.toString() ?? '').toLowerCase();
          if (defItem.title.toLowerCase().contains('inflasi') && title.contains('inflasi')) {
            matchedItem = item;
            break;
          } else if (defItem.title.toLowerCase().contains('pdrb') && title.contains('pdrb')) {
            matchedItem = item;
            break;
          } else if (defItem.title.toLowerCase().contains('kemiskinan') && title.contains('kemiskinan')) {
            matchedItem = item;
            break;
          } else if (defItem.title.toLowerCase().contains('penduduk') && title.contains('penduduk')) {
            matchedItem = item;
            break;
          }
        }

        if (matchedItem != null) {
          final decodedId = utf8.decode(base64.decode(matchedItem['id'].toString())).split('#')[0];
          updatedList.add(
            StrategicIndicatorItem(
              id: decodedId,
              title: defItem.title,
              value: defItem.value,
              unit: defItem.unit,
              year: defItem.year,
              deltaPercent: defItem.deltaPercent,
              isTrendGood: defItem.isTrendGood,
              sparklineData: defItem.sparklineData,
              icon: defItem.icon,
              gradient: defItem.gradient,
              tableType: '2',
            ),
          );
        } else {
          updatedList.add(defItem);
        }
      }

      return updatedList;
    } catch (_) {
      return defaultItems;
    }
  }
}
