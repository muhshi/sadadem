import 'package:Dalem/components/bar.dart';
import 'package:Dalem/components/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Dalem/components/offline_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/config/api_config.dart';

class DataTableScreen extends StatefulWidget {
  final String id;
  final String title;
  final String tableType;

  const DataTableScreen({
    super.key,
    required this.id,
    required this.title,
    required this.tableType,
  });

  @override
  DataTableScreenState createState() => DataTableScreenState();
}

class DataTableScreenState extends State<DataTableScreen> {
  late Future<Map<String, dynamic>> futureDataTable;
  late int selectedYear;

  List<int> get _availableYears {
    final currentYear = DateTime.now().year;
    final minYear = (currentYear - 3 < 2023) ? 2023 : (currentYear - 3);
    final years = <int>[];
    for (var y = currentYear; y >= minYear; y--) {
      years.add(y);
    }
    return years;
  }

  @override
  void initState() {
    super.initState();
    selectedYear = _availableYears.first;
    futureDataTable = fetchDataTable();
  }

  Future<Map<String, dynamic>> _fetchWithCache(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 12),
          );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final Map<String, dynamic> castedResponse =
            (jsonResponse as Map).cast<String, dynamic>();
        await OfflineStorage.saveData(url, castedResponse);
        return castedResponse;
      } else {
        throw Exception(
            'Gagal mengambil data dari API, status: ${response.statusCode}');
      }
    } catch (e) {
      final offlineData = await OfflineStorage.loadData(url);
      if (offlineData != null) {
        return offlineData.cast<String, dynamic>();
      } else {
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> fetchDataTable() async {
    final idParts = widget.id.split('#');
    final idOnly = idParts[0];

    if (widget.tableType == '1') {
      final url = ApiConfig.viewUrl(model: 'statictable', id: idOnly);
      return _fetchWithCache(url);
    } else if (widget.tableType == '2') {
      final url = ApiConfig.dataUrl(varId: idOnly);
      return _fetchWithCache(url);
    } else if (widget.tableType == '3') {
      final url = ApiConfig.simdasiUrl(idTabel: idOnly, tahun: selectedYear);
      try {
        final res = await _fetchWithCache(url);
        final rows = (res['data'] is List && (res['data'] as List).length > 1)
            ? ((res['data'][1] as Map?)?['data'] as List?)?.length ?? 0
            : 0;

        if (rows > 0) {
          return res;
        }

        // If currently selected year has no rows, check other available years
        for (var y in _availableYears) {
          if (y == selectedYear) continue;
          final fallbackUrl = ApiConfig.simdasiUrl(idTabel: idOnly, tahun: y);
          try {
            final fallbackRes = await _fetchWithCache(fallbackUrl);
            final fallbackRows = (fallbackRes['data'] is List && (fallbackRes['data'] as List).length > 1)
                ? ((fallbackRes['data'][1] as Map?)?['data'] as List?)?.length ?? 0
                : 0;
            if (fallbackRows > 0) {
              selectedYear = y;
              return fallbackRes;
            }
          } catch (_) {}
        }
        return res;
      } catch (_) {
        return _fetchWithCache(url);
      }
    } else {
      throw Exception('Tipe tabel tidak dikenali');
    }
  }

  Widget _buildYearSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primaryNavy),
              ),
              const SizedBox(width: 8),
              Text(
                'Pilih Tahun Data:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableYears.map((year) {
                final isSelected = selectedYear == year;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      if (selectedYear != year) {
                        setState(() {
                          selectedYear = year;
                          futureDataTable = _fetchWithCache(
                            ApiConfig.simdasiUrl(
                              idTabel: widget.id.split('#')[0],
                              tahun: year,
                            ),
                          );
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [AppColors.primaryNavy, AppColors.primaryLight],
                              )
                            : null,
                        color: isSelected ? null : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryNavy.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            '$year',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _colorToHex(Color c) {
    final r = (c.r * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    final g = (c.g * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    final b = (c.b * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }

  String _decodeHtml(String html) {
    return html
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&');
  }

  List<Map<String, dynamic>> _getActiveTahun(List<Map<String, dynamic>> rawTahun) {
    if (rawTahun.isEmpty) return [];
    final currentYear = DateTime.now().year;
    final minYear = (currentYear - 3 < 2023) ? 2023 : (currentYear - 3);

    // 1. If table has data for recent years (>= minYear e.g. 2023, 2024, 2025, 2026), filter to only those
    final recentYears = rawTahun.where((t) {
      final label = t['label']?.toString() ?? '';
      final yearNum = int.tryParse(label.replaceAll(RegExp(r'[^0-9]'), ''));
      if (yearNum != null) {
        return yearNum >= minYear;
      }
      return false;
    }).toList();

    if (recentYears.isNotEmpty) {
      return recentYears;
    }

    // 2. If table is historical only (data exists before 2023), show its available years (up to the last 5 years)
    if (rawTahun.length > 5) {
      return rawTahun.sublist(rawTahun.length - 5);
    }
    return rawTahun;
  }

  String generateSimdasiHtmlTable(Map<String, dynamic> tableObj) {
    final headerBg = _colorToHex(AppColors.primaryNavy);
    final headerBorder = _colorToHex(AppColors.primaryDark);

    final rawKolom = tableObj['kolom'];
    final rawData = tableObj['data'];

    if (rawKolom is! Map || rawData is! List || rawData.isEmpty) {
      return '<p style="text-align:center; padding: 20px; color: #64748B;">Data tabel tidak tersedia.</p>';
    }

    final Map<String, dynamic> kolomMap = rawKolom.cast<String, dynamic>();
    final List<dynamic> rowsList = rawData;

    var html = '''
    <table border="1" style="width: 100%; border-collapse: collapse; font-family: 'Plus Jakarta Sans', sans-serif; font-size: 12px; border: 1px solid #E2E8F0;">
      <thead>
        <tr style="background-color: $headerBg; color: white;">
          <th style="border: 1px solid $headerBorder; padding: 10px 12px; text-align: center; font-weight: 700;">Wilayah / Kecamatan</th>
    ''';

    for (var entry in kolomMap.entries) {
      final colData = entry.value as Map<String, dynamic>? ?? {};
      final colName = colData['nama_variabel']?.toString() ?? entry.key;
      final rawSatuan = colData['satuan']?.toString() ?? '';
      final satuan = rawSatuan.isNotEmpty ? ' ($rawSatuan)' : '';
      html +=
          '<th style="border: 1px solid $headerBorder; padding: 10px 12px; text-align: center; font-weight: 700;">$colName$satuan</th>';
    }

    html += '</tr></thead><tbody>';

    int rowIndex = 0;
    for (var row in rowsList) {
      if (row is! Map) continue;
      final bg = (rowIndex % 2 == 0) ? '#FFFFFF' : '#F8FAFC';
      final label = row['label']?.toString() ?? '';
      final variables = (row['variables'] as Map?)?.cast<String, dynamic>() ?? {};

      html += '<tr style="background-color: $bg;">';
      html +=
          '<td style="border: 1px solid #E2E8F0; padding: 8px 12px; text-align: left; font-weight: 500; color: #1E293B;">$label</td>';

      for (var colKey in kolomMap.keys) {
        final varObj = variables[colKey];
        String val = '-';
        if (varObj is Map && varObj['value'] != null) {
          val = varObj['value'].toString();
        } else if (varObj != null) {
          val = varObj.toString();
        }
        html +=
            '<td style="border: 1px solid #E2E8F0; padding: 8px 12px; text-align: right; font-weight: 600; color: #0F172A;">$val</td>';
      }

      html += '</tr>';
      rowIndex++;
    }

    html += '</tbody></table>';

    final sumber = tableObj['sumber']?.toString();
    if (sumber != null && sumber.isNotEmpty) {
      final decodedSumber = _decodeHtml(sumber);
      html += '<div style="margin-top: 12px; font-size: 11px; color: #64748B;">$decodedSumber</div>';
    }

    return html;
  }

  String generateSimdasiCsv(Map<String, dynamic> tableObj) {
    final rawKolom = tableObj['kolom'];
    final rawData = tableObj['data'];

    if (rawKolom is! Map || rawData is! List || rawData.isEmpty) {
      return '';
    }

    final Map<String, dynamic> kolomMap = rawKolom.cast<String, dynamic>();
    final List<dynamic> rowsList = rawData;

    List<List<String>> csvData = [];

    // Header
    List<String> header = ['Wilayah / Kecamatan'];
    for (var entry in kolomMap.entries) {
      final colData = entry.value as Map<String, dynamic>? ?? {};
      final colName = colData['nama_variabel']?.toString() ?? entry.key;
      final rawSatuan = colData['satuan']?.toString() ?? '';
      final satuan = rawSatuan.isNotEmpty ? ' ($rawSatuan)' : '';
      header.add('$colName$satuan');
    }
    csvData.add(header);

    // Rows
    for (var row in rowsList) {
      if (row is! Map) continue;
      final label = row['label']?.toString() ?? '';
      final variables = (row['variables'] as Map?)?.cast<String, dynamic>() ?? {};
      List<String> rowData = [label];

      for (var colKey in kolomMap.keys) {
        final varObj = variables[colKey];
        String val = '-';
        if (varObj is Map && varObj['value'] != null) {
          val = varObj['value'].toString();
        } else if (varObj != null) {
          val = varObj.toString();
        }
        rowData.add(val);
      }
      csvData.add(rowData);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  String generateHtmlTable(Map<String, dynamic> data) {
    final headerBg = _colorToHex(AppColors.primaryNavy);
    final headerBorder = _colorToHex(AppColors.primaryDark);

    final varData =
        (data["var"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final vervarData =
        (data["vervar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final turvarData =
        (data["turvar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final dataContent =
        (data["datacontent"] as Map?)?.cast<String, dynamic>() ?? {};
    final rawTahun =
        (data["tahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final tahun = _getActiveTahun(rawTahun);
    final turTahun =
        (data["turtahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            [];

    if (vervarData.isEmpty || tahun.isEmpty) {
      return '<p style="text-align:center; padding: 20px; color: #64748B;">Data tabel tidak tersedia untuk rentang tahun ini.</p>';
    }

    final turTahunVal = turTahun.isNotEmpty ? turTahun[0]['val'] : 0;
    final vervarLabel = data['labelvervar']?.toString() ?? 'Kategori';

    var html = '''
    <table border="1" style="width: 100%; border-collapse: collapse; font-family: 'Plus Jakarta Sans', sans-serif; font-size: 12px; border: 1px solid #E2E8F0;">
      <thead>
        <tr style="background-color: $headerBg; color: white;">
          <th rowspan="3" style="border: 1px solid $headerBorder; padding: 10px 12px; text-align: center; font-weight: 700;">$vervarLabel</th>
    ''';

    for (var varItem in varData) {
      final colSpan = tahun.length * (turvarData.isNotEmpty ? turvarData.length : 1);
      html +=
          '<th colspan="$colSpan" style="border: 1px solid $headerBorder; padding: 10px 12px; text-align: center; font-weight: 700;">${varItem['label']}</th>';
    }
    html +=
        '</tr><tr style="background-color: $headerBg; color: white;">';

    for (var _ in varData) {
      if (turvarData.isNotEmpty) {
        for (var element in turvarData) {
          html +=
              '<th colspan="${tahun.length}" style="border: 1px solid $headerBorder; padding: 10px 12px; text-align: center; font-weight: 700;">${element['label'] == 'Tidak Ada' || element['label'] == 'Tidak ada' ? 'Tahun' : element['label']}</th>';
        }
      } else {
        html +=
            '<th colspan="${tahun.length}" style="border: 1px solid $headerBorder; padding: 10px 12px; text-align: center; font-weight: 700;">Tahun</th>';
      }
    }

    html +=
        '</tr><tr style="background-color: $headerBg; color: white;">';

    for (var _ in varData) {
      final tVars = turvarData.isNotEmpty ? turvarData : [{'val': 0}];
      for (var _ in tVars) {
        for (var element in tahun) {
          html +=
              '<th style="border: 1px solid $headerBorder; padding: 10px 12px; text-align: center; font-weight: 700;">${element['label']}</th>';
        }
      }
    }

    html += '</tr></thead><tbody>';

    int rowIndex = 0;
    for (var vervar in vervarData) {
      final bg = (rowIndex % 2 == 0) ? '#FFFFFF' : '#F8FAFC';
      html += '<tr style="background-color: $bg;">';
      html +=
          '<td style="border: 1px solid #E2E8F0; padding: 8px 12px; text-align: left; font-weight: 500; color: #1E293B;">${vervar['label']}</td>';
      for (var varItem in varData) {
        final tVars = turvarData.isNotEmpty ? turvarData : [{'val': 0}];
        for (var turvar in tVars) {
          for (var tahunItem in tahun) {
            final key =
                "${vervar["val"]}${varItem["val"]}${turvar["val"]}${tahunItem['val']}$turTahunVal";
            String value = dataContent[key]?.toString() ?? '-';
            if (value != '-') {
              value = value.replaceAll('.', ',');
              value = value.replaceAllMapped(
                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
            }
            html +=
                '<td style="border: 1px solid #E2E8F0; padding: 8px 12px; text-align: right; font-weight: 600; color: #0F172A;">$value</td>';
          }
        }
      }
      html += '</tr>';
      rowIndex++;
    }

    html += '</tbody></table>';

    return html;
  }

  String generateCsv(Map<String, dynamic> data) {
    final varData =
        (data["var"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final vervarData =
        (data["vervar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final turvarData =
        (data["turvar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final dataContent =
        (data["datacontent"] as Map?)?.cast<String, dynamic>() ?? {};
    final rawTahun =
        (data["tahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final tahun = _getActiveTahun(rawTahun);
    final turTahun =
        (data["turtahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            [];

    final turTahunVal = turTahun.isNotEmpty ? turTahun[0]['val'] : 0;
    List<List<String>> csvData = [];

    // Header 1
    List<String> header1 = [''];
    for (var varItem in varData) {
      final count = tahun.length * (turvarData.isNotEmpty ? turvarData.length : 1);
      header1.addAll(List.filled(count, varItem['label']?.toString() ?? ''));
    }
    csvData.add(header1);

    // Header 2
    List<String> header2 = [data['labelvervar']?.toString() ?? 'Kategori'];
    for (var _ in varData) {
      if (turvarData.isNotEmpty) {
        for (var element in turvarData) {
          header2.addAll(List.filled(tahun.length,
              (element['label'] == 'Tidak Ada' || element['label'] == 'Tidak ada') ? 'Tahun' : element['label']));
        }
      } else {
        header2.addAll(List.filled(tahun.length, 'Tahun'));
      }
    }
    csvData.add(header2);

    // Header 3
    List<String> header3 = [''];
    for (var _ in varData) {
      final tVars = turvarData.isNotEmpty ? turvarData : [{'val': 0}];
      for (var _ in tVars) {
        for (var tahunItem in tahun) {
          header3.add(tahunItem['label']?.toString() ?? '');
        }
      }
    }
    csvData.add(header3);

    // Rows
    for (var vervar in vervarData) {
      List<String> row = [vervar['label']?.toString() ?? ''];
      for (var varItem in varData) {
        final tVars = turvarData.isNotEmpty ? turvarData : [{'val': 0}];
        for (var turvar in tVars) {
          for (var tahunItem in tahun) {
            final key =
                "${vervar["val"]}${varItem["val"]}${turvar["val"]}${tahunItem['val']}$turTahunVal";
            row.add(dataContent[key]?.toString() ?? '-');
          }
        }
      }
      csvData.add(row);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  Future<void> downloadCsv(String csv) async {
    try {
      final directory = Directory('/storage/emulated/0/Download/Dalem');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final safeId = widget.id.replaceAll('#', '_');
      final path = '${directory.path}/${widget.title}_$safeId.xls';
      final file = File(path);
      await file.writeAsString(csv);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
                  const SizedBox(width: 8),
                  Text('Unduhan Berhasil', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text('File tabel berhasil disimpan di:\n$path', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar2(
        title: 'Detail Tabel',
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureDataTable,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 30,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError ||
              snapshot.data is! Map<String, dynamic>) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.table_rows_rounded,
                        size: 64,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tabel Data Belum Tersedia',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data untuk tabel ini belum tersedia di server BPS.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          futureDataTable = fetchDataTable();
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            final data = snapshot.data!;

            // Check availability for static, SIMDASI, and dynamic tables
            bool isDataAvailable = true;
            String tableHtml = '';
            String? staticExcelUrl;
            Map<String, dynamic>? simdasiTableObj;

            if (widget.tableType == '1') {
              // Static table
              final staticData = data['data'];
              if (staticData != null && staticData is Map && staticData['table'] != null) {
                tableHtml = _decodeHtml(staticData['table'].toString());
                staticExcelUrl = staticData['excel']?.toString();
              } else {
                isDataAvailable = false;
              }
            } else if (widget.tableType == '3') {
              // SIMDASI table (interoperabilitas)
              if (data['data'] is List && (data['data'] as List).length > 1) {
                final tableObj = data['data'][1];
                if (tableObj is Map &&
                    tableObj['data'] is List &&
                    (tableObj['data'] as List).isNotEmpty) {
                  simdasiTableObj = tableObj.cast<String, dynamic>();
                  tableHtml = generateSimdasiHtmlTable(simdasiTableObj);
                } else {
                  isDataAvailable = false;
                }
              } else {
                isDataAvailable = false;
              }
            } else {
              // Dynamic table (tableType 2)
              final availability = data['data-availability']?.toString();
              final tahun = data['tahun'] as List<dynamic>?;
              final dataContent = data['datacontent'];
              if (availability == 'list-not-available' ||
                  availability == 'not-available' ||
                  tahun == null ||
                  tahun.isEmpty ||
                  (dataContent is List && dataContent.isEmpty) ||
                  (dataContent is Map && dataContent.isEmpty)) {
                isDataAvailable = false;
              } else {
                tableHtml = generateHtmlTable(data);
              }
            }

            if (!isDataAvailable || tableHtml.isEmpty) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (widget.tableType == '3') _buildYearSelector(),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.table_rows_rounded,
                        size: 64,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tabel Data Belum Tersedia',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.tableType == '3'
                          ? 'Data statistik untuk tahun $selectedYear belum tersedia di BPS Kabupaten Demak. Silakan pilih tahun lain di atas.'
                          : 'Data statistik untuk tabel ini belum tersedia dari BPS Kabupaten Demak.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.tableType == '3') _buildYearSelector(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          simdasiTableObj?['judul_tabel']?.toString() ?? widget.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: HtmlWidget(tableHtml),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Download button
                  if (widget.tableType == '1' && staticExcelUrl != null && staticExcelUrl.isNotEmpty)
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryNavy, AppColors.primaryLight],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryNavy.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () async {
                            final uri = Uri.parse(staticExcelUrl!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tidak dapat membuka link unduhan Excel.')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.download_rounded, color: Colors.white),
                          label: Text(
                            'Unduh Tabel (.xls)',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (widget.tableType == '3' && simdasiTableObj != null)
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryNavy, AppColors.primaryLight],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryNavy.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () async {
                            final csv = generateSimdasiCsv(simdasiTableObj!);
                            await downloadCsv(csv);
                          },
                          icon: const Icon(Icons.download_rounded, color: Colors.white),
                          label: Text(
                            'Unduh Tabel (.xls)',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (widget.tableType == '2' &&
                      data["datacontent"] != null &&
                      (data["datacontent"] is Map && (data["datacontent"] as Map).isNotEmpty))
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryNavy, AppColors.primaryLight],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryNavy.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () async {
                            final csv = generateCsv(data);
                            await downloadCsv(csv);
                          },
                          icon: const Icon(Icons.download_rounded, color: Colors.white),
                          label: Text(
                            'Unduh Tabel (.xls)',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        launchUrl(Uri.parse(
                            'https://ppid.bps.go.id/app/konten/3321/Profil-BPS.html?_gl=1*9iomf9*_ga*ODk0Njg5NDUyLjE3MzMzNjI0NDI.*_ga_XXTTVXWHDB*MTc0MDM2MTk3My40My4xLjE3NDAzNjIyODcuMC4wLjA.'));
                      },
                      child: Text(
                        'Hak Cipta © ${DateTime.now().year} Badan Pusat Statistik Kabupaten Demak',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}
