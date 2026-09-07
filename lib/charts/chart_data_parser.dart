import 'dart:math';
import 'package:flutter/material.dart';

/// Single data point for charting
class ChartDataPoint {
  final String label;
  final double value;
  final String formattedValue;

  const ChartDataPoint({
    required this.label,
    required this.value,
    required this.formattedValue,
  });
}

/// A series of points (e.g. one variable across regions, or one region across years)
class ChartSeries {
  final String name;
  final String unit;
  final List<ChartDataPoint> points;
  final Color color;
  final double? totalValue;
  final String? totalLabel;

  const ChartSeries({
    required this.name,
    required this.unit,
    required this.points,
    required this.color,
    this.totalValue,
    this.totalLabel,
  });

  bool get isEmpty => points.isEmpty;
  bool get isNotEmpty => points.isNotEmpty;

  double get maxValue {
    if (points.isEmpty) return 0;
    return points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
  }

  double get minValue {
    if (points.isEmpty) return 0;
    return points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
  }

  double get averageValue {
    if (points.isEmpty) return 0;
    final sum = points.map((p) => p.value).reduce((a, b) => a + b);
    return sum / points.length;
  }

  double get pointsSum {
    if (points.isEmpty) return 0;
    return points.map((p) => p.value).reduce((a, b) => a + b);
  }

  bool get isTemporal => points.any((p) =>
      RegExp(r'^(?:19|20)\d{2}\b').hasMatch(p.label) ||
      RegExp(r'^(?:Jan(?:uari)?|Feb(?:ruari)?|Mar(?:et)?|Apr(?:il)?|Mei|Jun(?:i)?|Jul(?:i)?|Agu(?:stus)?|Sep(?:tember)?|Okt(?:ober)?|Nov(?:ember)?|Des(?:ember)?)\b',
              caseSensitive: false)
          .hasMatch(p.label));

  /// Determines if bottom horizontal labels should be hidden to avoid dense overlapping text.
  /// (e.g. 19 villages with long names). Users see names via tooltip by tapping/dragging.
  bool get shouldHideBottomTitles {
    if (isTemporal) return false;
    if (points.length > 4) return true;
    final maxLen = points.isEmpty
        ? 0
        : points.map((p) => p.label.length).reduce((a, b) => a > b ? a : b);
    return maxLen > 7;
  }
}

/// Year-over-Year (YoY) comparison summary
class YoyComparison {
  final double currentValue;
  final double previousValue;
  final double deltaPercent;
  final String currentPeriod;
  final String previousPeriod;
  final String unit;

  const YoyComparison({
    required this.currentValue,
    required this.previousValue,
    required this.deltaPercent,
    required this.currentPeriod,
    required this.previousPeriod,
    required this.unit,
  });

  bool get isPositive => deltaPercent > 0;
  bool get isNegative => deltaPercent < 0;
  bool get isZero => deltaPercent.abs() < 0.001;

  String get deltaPercentText {
    final prefix = isPositive ? '+' : '';
    return '$prefix${deltaPercent.toStringAsFixed(2)}%';
  }
}

/// Utility class to parse BPS API responses into structured chart data
class ChartDataParser {
  // Preset color palette for multi-series
  static const List<Color> seriesColors = [
    Color(0xFFE8611A), // SE2026 Vibrant Orange
    Color(0xFF0D3D85), // Deep Royal Navy
    Color(0xFF059669), // Emerald Green
    Color(0xFF7C3AED), // Purple/Violet
    Color(0xFFD97706), // Amber
    Color(0xFF0284C7), // Sky Blue
    Color(0xFFDC2626), // Rose Red
    Color(0xFF4F46E5), // Indigo
  ];

  /// Safely parse numeric value from dynamic input (handles ID formatting '1.234,56' or '1234.56')
  static double? parseNumeric(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();

    String str = raw.toString().trim();
    if (str.isEmpty || str == '-' || str == 'null' || str == 'Tidak ada') {
      return null;
    }

    // Strip currency symbols and whitespace
    str = str.replaceAll(RegExp(r'[^\d.,\-]'), '');

    // Check if format is Indonesian '1.234,56' (contains dot followed by comma)
    if (str.contains('.') && str.contains(',')) {
      if (str.indexOf('.') < str.indexOf(',')) {
        str = str.replaceAll('.', '').replaceAll(',', '.');
      } else {
        str = str.replaceAll(',', '');
      }
    } else if (str.contains(',')) {
      // If comma is thousand separator (e.g. 1,837 or 12,345,678)
      if (RegExp(r'^-?\d{1,3}(,\d{3})+$').hasMatch(str)) {
        str = str.replaceAll(',', '');
      } else {
        str = str.replaceAll(',', '.');
      }
    }

    return double.tryParse(str);
  }

  /// Format double to Indonesian readable string
  static String formatIndonesianNumber(double val, {int maxDecimals = 2}) {
    if (val.isNaN || val.isInfinite) return '-';

    // If maxDecimals is 0 or it's an exact integer
    if (maxDecimals <= 0 || val == val.roundToDouble()) {
      final intVal = val.round();
      return intVal.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          );
    }

    final parts = val.toStringAsFixed(maxDecimals).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    if (parts.length < 2) {
      return integerPart;
    }
    final decimalPart = parts[1].replaceFirst(RegExp(r'0+$'), '');
    return decimalPart.isEmpty ? integerPart : '$integerPart,$decimalPart';
  }

  /// Calculates a human-friendly "nice" interval for Y-axis (e.g. 0.5, 1, 2, 5, 10, 20, 50, etc.)
  static double calculateNiceYInterval(double yRange, {int targetTicks = 4}) {
    if (yRange <= 0 || yRange.isNaN || yRange.isInfinite) return 1.0;
    final rawInterval = yRange / targetTicks;
    if (rawInterval <= 0) return 1.0;

    final magnitude = pow(10, (log(rawInterval) / ln10).floor()).toDouble();
    final normalized = rawInterval / magnitude;

    double niceNormalized;
    if (normalized < 1.5) {
      niceNormalized = 1.0;
    } else if (normalized < 3.0) {
      niceNormalized = 2.0;
    } else if (normalized < 7.0) {
      niceNormalized = 5.0;
    } else {
      niceNormalized = 10.0;
    }
    return niceNormalized * magnitude;
  }

  static String _shortMonth(String monthName) {
    final lower = monthName.toLowerCase().trim();
    if (lower.startsWith('jan')) return 'Jan';
    if (lower.startsWith('feb')) return 'Feb';
    if (lower.startsWith('mar')) return 'Mar';
    if (lower.startsWith('apr')) return 'Apr';
    if (lower.startsWith('mei') || lower.startsWith('may')) return 'Mei';
    if (lower.startsWith('jun')) return 'Jun';
    if (lower.startsWith('jul')) return 'Jul';
    if (lower.startsWith('agu') || lower.startsWith('aug')) return 'Agu';
    if (lower.startsWith('sep')) return 'Sep';
    if (lower.startsWith('okt') || lower.startsWith('oct')) return 'Okt';
    if (lower.startsWith('nov')) return 'Nov';
    if (lower.startsWith('des') || lower.startsWith('dec')) return 'Des';
    return monthName.length > 3 ? monthName.substring(0, 3) : monthName;
  }

  /// Check if a row label represents an aggregate/summary row (e.g. Jumlah, Total, Rata-rata)
  /// that should not be plotted as an individual categorical data point.
  static bool isAggregateRowLabel(String rawLabel) {
    final clean = rawLabel.replaceAll(RegExp(r'<[^>]*>'), '').trim().toLowerCase();
    if (clean.isEmpty) return false;

    if (clean == 'jumlah' ||
        clean == 'total' ||
        clean == 'jumlah total' ||
        clean == 'grand total' ||
        clean == 'rata-rata' ||
        clean == 'rerata' ||
        clean == 'average' ||
        clean == 'mean') {
      return true;
    }

    final pattern = RegExp(
      r'^(?:jumlah|total)(?:\s*(?:[\/|–—\-]|\()\s*(?:total|jumlah)[\)]?)?$',
      caseSensitive: false,
    );
    if (pattern.hasMatch(clean)) return true;

    if ((clean.startsWith('jumlah') || clean.startsWith('total')) &&
        (clean.contains('/total') ||
            clean.contains('/ total') ||
            clean.contains('/jumlah') ||
            clean.contains('/ jumlah') ||
            clean.contains('(total)') ||
            clean.contains('(jumlah)'))) {
      return true;
    }

    if (clean.contains('kecamatan') || clean.contains('kabupaten')) {
      if (clean.contains('total') || clean.contains('jumlah') || clean.contains('seluruh')) {
        return true;
      }
    }

    return false;
  }

  /// Post-process and sanitize a series to ensure aggregate rows (e.g. Kecamatan total,
  /// Kabupaten total, or summary sums) are not plotted alongside individual sub-entities.
  static ChartSeries sanitizeSeries(ChartSeries series) {
    if (series.points.length < 3) return series;

    final points = List<ChartDataPoint>.from(series.points);
    double? totalVal = series.totalValue;
    String? totalLbl = series.totalLabel;

    // 1. Check if the last point is an aggregate (label check OR mathematical sum match)
    final lastPoint = points.last;
    final otherSum = points.sublist(0, points.length - 1).fold<double>(0, (s, p) => s + p.value);
    final lastLower = lastPoint.label.toLowerCase().trim();

    final bool isLastExplicitAggregate = isAggregateRowLabel(lastPoint.label);
    final bool isLastRegionAggregate = lastLower.startsWith('kecamatan') ||
        lastLower.startsWith('kec.') ||
        lastLower.startsWith('kabupaten') ||
        lastLower.startsWith('kab.') ||
        lastLower.contains('demak');

    final bool isLastSumMatch = otherSum > 0 &&
        ((lastPoint.value - otherSum).abs() / otherSum < 0.04 ||
            (lastPoint.value >= otherSum * 0.90 && lastPoint.value <= otherSum * 1.10));

    if (isLastExplicitAggregate ||
        (isLastRegionAggregate && lastPoint.value > otherSum * 0.4) ||
        isLastSumMatch) {
      totalVal ??= lastPoint.value;
      totalLbl ??= lastPoint.label;
      points.removeLast();
    }

    // 2. Check if the first point is an aggregate
    if (points.length >= 3) {
      final firstPoint = points.first;
      final restSum = points.sublist(1).fold<double>(0, (s, p) => s + p.value);
      final bool isFirstExplicitAggregate = isAggregateRowLabel(firstPoint.label);
      final bool isFirstSumMatch = restSum > 0 &&
          ((firstPoint.value - restSum).abs() / restSum < 0.04);

      if (isFirstExplicitAggregate || isFirstSumMatch) {
        totalVal ??= firstPoint.value;
        totalLbl ??= firstPoint.label;
        points.removeAt(0);
      }
    }

    return ChartSeries(
      name: series.name,
      unit: series.unit,
      points: points,
      color: series.color,
      totalValue: totalVal,
      totalLabel: totalLbl,
    );
  }

  /// Parse SIMDASI Table Data (Tipe 3)
  static List<ChartSeries> parseSimdasi(Map<String, dynamic> tableObj) {
    final rawKolom = tableObj['kolom'];
    final rawData = tableObj['data'];

    if (rawKolom is! Map || rawData is! List || rawData.isEmpty) {
      return [];
    }

    final Map<String, dynamic> kolomMap = rawKolom.cast<String, dynamic>();
    final List<dynamic> rowsList = rawData;
    final List<ChartSeries> seriesList = [];
    int colorIdx = 0;

    for (var entry in kolomMap.entries) {
      final colKey = entry.key;
      final colData = entry.value as Map<String, dynamic>? ?? {};
      final colName = colData['nama_variabel']?.toString() ?? colKey;
      final rawSatuan = colData['satuan']?.toString() ?? '';
      final rawMultiplier = colData['unit_multiplier_desc']?.toString() ?? '';
      final rawUnit = colData['unit']?.toString() ?? '';

      String unitText = '';
      if (rawMultiplier.isNotEmpty && rawMultiplier != 'null' && rawMultiplier != '-') {
        if (rawSatuan.isNotEmpty && rawSatuan != 'null' && rawSatuan != '-') {
          unitText = '$rawMultiplier $rawSatuan';
        } else {
          unitText = rawMultiplier;
        }
      } else if (rawSatuan.isNotEmpty && rawSatuan != 'null' && rawSatuan != '-') {
        unitText = rawSatuan;
      } else if (rawUnit.isNotEmpty && rawUnit != 'null' && rawUnit != '-') {
        unitText = rawUnit;
      }

      final List<ChartDataPoint> points = [];
      double? capturedTotalValue;
      String? capturedTotalLabel;

      for (var row in rowsList) {
        if (row is! Map) continue;
        final rawLabel = row['label']?.toString() ?? '';
        final cleanLabel = rawLabel.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        if (cleanLabel.isEmpty) continue;

        final variables = (row['variables'] as Map?)?.cast<String, dynamic>() ?? {};
        final varObj = variables[colKey];

        double? numVal;
        if (varObj is Map && varObj['value'] != null) {
          numVal = parseNumeric(varObj['value']);
        } else if (varObj != null) {
          numVal = parseNumeric(varObj);
        }

        if (numVal != null) {
          // If this row is an aggregate summary (Jumlah/Total), do NOT add it as a point to avoid scale distortion
          if (isAggregateRowLabel(cleanLabel) && rowsList.length > 1) {
            capturedTotalValue = numVal;
            capturedTotalLabel = cleanLabel;
            continue;
          }

          points.add(
            ChartDataPoint(
              label: cleanLabel,
              value: numVal,
              formattedValue: formatIndonesianNumber(numVal),
            ),
          );
        }
      }

      if (points.isNotEmpty) {
        final rawSeries = ChartSeries(
          name: colName,
          unit: unitText,
          points: points,
          color: seriesColors[colorIdx % seriesColors.length],
          totalValue: capturedTotalValue,
          totalLabel: capturedTotalLabel,
        );
        seriesList.add(sanitizeSeries(rawSeries));
        colorIdx++;
      }
    }

    return seriesList;
  }

  /// Parse Dynamic Table Data (Tipe 2)
  /// Properly distinguishes turvar & turtahun to prevent duplicate year collisions
  static List<ChartSeries> parseDynamic(
    Map<String, dynamic> data, {
    List<Map<String, dynamic>>? filteredTahun,
  }) {
    final varData =
        (data["var"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final vervarData =
        (data["vervar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final turvarData =
        (data["turvar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final dataContent =
        (data["datacontent"] as Map?)?.cast<String, dynamic>() ?? {};
    final currentYear = DateTime.now().year;
    final minYear = (currentYear - 3 < 2023) ? 2023 : (currentYear - 3);

    final rawTahun =
        (data["tahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    // Filter rawTahun to only recent years (>= minYear / 2023 s.d. currentYear)
    final recentTahun = rawTahun.where((t) {
      final label = t['label']?.toString() ?? '';
      final yearNum = int.tryParse(label.replaceAll(RegExp(r'[^0-9]'), ''));
      if (yearNum != null) {
        return yearNum >= minYear && yearNum <= currentYear;
      }
      return false;
    }).toList();

    // Use filteredTahun if provided, but still guard against years < minYear if recent data exists
    final List<Map<String, dynamic>> tahun;
    if (filteredTahun != null && filteredTahun.isNotEmpty) {
      final safeFiltered = filteredTahun.where((t) {
        final label = t['label']?.toString() ?? '';
        final yearNum = int.tryParse(label.replaceAll(RegExp(r'[^0-9]'), ''));
        if (yearNum != null && recentTahun.isNotEmpty) {
          return yearNum >= minYear && yearNum <= currentYear;
        }
        return true;
      }).toList();
      tahun = safeFiltered.isNotEmpty ? safeFiltered : filteredTahun;
    } else {
      tahun = recentTahun.isNotEmpty ? recentTahun : rawTahun;
    }

    final turTahun =
        (data["turtahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    if (vervarData.isEmpty || tahun.isEmpty) {
      return [];
    }

    // Detect sub-annual periods (monthly / quarterly)
    final bool isSubAnnual = turTahun.length > 1;
    final List<Map<String, dynamic>> activeTurTahun = isSubAnnual
        ? turTahun.where((tt) {
            final label = tt['label']?.toString().toLowerCase() ?? '';
            return !label.contains('tahunan') && !label.contains('total');
          }).toList()
        : turTahun;

    String unit = '';
    for (var varItem in varData) {
      final rawUnit = varItem['unit']?.toString() ?? varItem['satuan']?.toString() ?? '';
      if (rawUnit.isNotEmpty && rawUnit != 'null' && rawUnit != '-') {
        unit = rawUnit;
        break;
      }
    }

    final tVars = turvarData.isNotEmpty ? turvarData : [{'val': 0, 'label': ''}];
    final List<ChartSeries> seriesList = [];
    int colorIdx = 0;

    for (var vervar in vervarData) {
      final vervarLabel = vervar['label']?.toString() ?? '';

      for (var turvar in tVars) {
        final turvarLabel = turvar['label']?.toString() ?? '';
        final isTurvarMeaningful = turvarLabel.isNotEmpty &&
            turvarLabel != 'null' &&
            turvarLabel != '-' &&
            !turvarLabel.toLowerCase().contains('tidak ada');

        String seriesName = vervarLabel;
        if (vervarData.length == 1 && isTurvarMeaningful) {
          seriesName = turvarLabel;
        } else if (isTurvarMeaningful) {
          seriesName = '$vervarLabel ($turvarLabel)';
        }

        final List<ChartDataPoint> points = [];

        for (var varItem in varData) {
          for (var tahunItem in tahun) {
            final tahunLabel = tahunItem['label']?.toString() ?? '';
            final shortYr = tahunLabel.length >= 4 ? tahunLabel.substring(2) : tahunLabel;

            if (isSubAnnual && activeTurTahun.isNotEmpty) {
              for (var tt in activeTurTahun) {
                final ttLabel = tt['label']?.toString() ?? '';
                final ptLabel = tahun.length > 1
                    ? '${_shortMonth(ttLabel)} \'$shortYr'
                    : _shortMonth(ttLabel);

                final key =
                    "${vervar["val"]}${varItem["val"]}${turvar["val"]}${tahunItem['val']}${tt['val']}";
                final numVal = parseNumeric(dataContent[key]);
                if (numVal != null) {
                  points.add(
                    ChartDataPoint(
                      label: ptLabel,
                      value: numVal,
                      formattedValue: formatIndonesianNumber(numVal),
                    ),
                  );
                }
              }
            } else {
              final turTahunVal = turTahun.isNotEmpty ? turTahun[0]['val'] : 0;
              final key =
                  "${vervar["val"]}${varItem["val"]}${turvar["val"]}${tahunItem['val']}$turTahunVal";
              final numVal = parseNumeric(dataContent[key]);
              if (numVal != null) {
                points.add(
                  ChartDataPoint(
                    label: tahunLabel,
                    value: numVal,
                    formattedValue: formatIndonesianNumber(numVal),
                  ),
                );
              }
            }
          }
        }

        if (points.isNotEmpty) {
          seriesList.add(
            ChartSeries(
              name: seriesName,
              unit: unit,
              points: points,
              color: seriesColors[colorIdx % seriesColors.length],
            ),
          );
          colorIdx++;
        }
      }
    }

    // Prioritize primary/aggregate series (Demak, Total, Jumlah) to the top
    seriesList.sort((a, b) {
      final aLower = a.name.toLowerCase();
      final bLower = b.name.toLowerCase();
      final aIsAggregate = aLower.contains('demak') || aLower.contains('total') || aLower.contains('jumlah');
      final bIsAggregate = bLower.contains('demak') || bLower.contains('total') || bLower.contains('jumlah');
      if (aIsAggregate && !bIsAggregate) return -1;
      if (!aIsAggregate && bIsAggregate) return 1;
      return 0;
    });

    return seriesList;
  }

  /// Parse Static Table HTML (Tipe 1)
  /// Extracts structured rows and numeric columns from standard BPS HTML tables
  static List<ChartSeries> parseStaticHtml(String rawHtml) {
    if (rawHtml.isEmpty) return [];

    final html = rawHtml
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#039;', "'")
        .replaceAll('&apos;', "'");

    final trRegex = RegExp(r'<tr[^>]*>(.*?)<\/tr>', dotAll: true, caseSensitive: false);
    final cellRegex = RegExp(r'<(?:td|th)[^>]*>(.*?)<\/(?:td|th)>', dotAll: true, caseSensitive: false);

    final rows = <List<String>>[];
    for (var trMatch in trRegex.allMatches(html)) {
      final rowHtml = trMatch.group(1) ?? '';
      final cells = <String>[];
      for (var cellMatch in cellRegex.allMatches(rowHtml)) {
        var cellText = cellMatch.group(1) ?? '';
        cellText = cellText.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        cells.add(cellText);
      }
      if (cells.any((c) => c.isNotEmpty)) {
        rows.add(cells);
      }
    }

    if (rows.length < 2) return [];

    int headerRowIdx = -1;
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.length >= 2) {
        final firstNum = parseNumeric(row[0]);
        if (firstNum == null && row[0].isNotEmpty) {
          if (i + 1 < rows.length && rows[i + 1].length >= 2) {
            final nextNum = parseNumeric(rows[i + 1][1]);
            if (nextNum != null) {
              headerRowIdx = i;
              break;
            }
          }
        }
      }
    }

    if (headerRowIdx == -1) return [];

    final headerRow = rows[headerRowIdx];
    final dataRows = rows.sublist(headerRowIdx + 1);
    final seriesList = <ChartSeries>[];

    for (int col = 1; col < headerRow.length; col++) {
      final colName = headerRow[col].isNotEmpty ? headerRow[col] : 'Kolom $col';
      final points = <ChartDataPoint>[];
      double? capturedTotalValue;
      String? capturedTotalLabel;

      for (var dRow in dataRows) {
        if (dRow.length <= col) continue;
        final rawLabel = dRow[0];
        final cleanLabel = rawLabel.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        if (cleanLabel.isEmpty) continue;
        if (cleanLabel.toLowerCase().startsWith('catatan') ||
            cleanLabel.toLowerCase().startsWith('sumber') ||
            cleanLabel.toLowerCase().startsWith('keterangan')) {
          continue;
        }
        final rawVal = dRow[col];
        final numVal = parseNumeric(rawVal);
        if (numVal != null) {
          if (isAggregateRowLabel(cleanLabel) && dataRows.length > 2) {
            capturedTotalValue = numVal;
            capturedTotalLabel = cleanLabel;
            continue; // Do NOT plot aggregate total in chart!
          }

          points.add(
            ChartDataPoint(
              label: cleanLabel,
              value: numVal,
              formattedValue: formatIndonesianNumber(numVal),
            ),
          );
        }
      }

      if (points.isNotEmpty) {
        final rawSeries = ChartSeries(
          name: colName,
          unit: '',
          points: points,
          color: seriesColors[(col - 1) % seriesColors.length],
          totalValue: capturedTotalValue,
          totalLabel: capturedTotalLabel,
        );
        seriesList.add(sanitizeSeries(rawSeries));
      }
    }

    return seriesList;
  }

  /// Calculate Year-over-Year comparison from a series
  /// Only calculates YoY if points are temporal periods (years or months/quarters)
  static YoyComparison? calculateYoy(ChartSeries series) {
    if (series.points.length < 2) return null;

    // Check if points are temporal
    final isTemporal = series.points.any((p) =>
        RegExp(r'^(?:19|20)\d{2}').hasMatch(p.label) ||
        RegExp(r'^(?:Jan|Feb|Mar|Apr|Mei|Jun|Jul|Agu|Sep|Okt|Nov|Des)', caseSensitive: false)
            .hasMatch(p.label));
    if (!isTemporal) return null;

    final prev = series.points[series.points.length - 2];
    final current = series.points.last;

    if (prev.value == 0) {
      return YoyComparison(
        currentValue: current.value,
        previousValue: prev.value,
        deltaPercent: 0,
        currentPeriod: current.label,
        previousPeriod: prev.label,
        unit: series.unit,
      );
    }

    final delta = ((current.value - prev.value) / prev.value.abs()) * 100.0;
    return YoyComparison(
      currentValue: current.value,
      previousValue: prev.value,
      deltaPercent: delta,
      currentPeriod: current.label,
      previousPeriod: prev.label,
      unit: series.unit,
    );
  }
}
