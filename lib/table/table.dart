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

  @override
  void initState() {
    super.initState();
    futureDataTable = fetchDataTable();
  }

  Future<Map<String, dynamic>> fetchDataTable() async {
    String url;
    final idParts = widget.id.split('#');
    final idOnly = idParts[0];

    if (widget.tableType == '1') {
      url = ApiConfig.viewUrl(model: 'statictable', id: idOnly);
    } else if (widget.tableType == '2') {
      url = ApiConfig.dataUrl(varId: idOnly);
    } else {
      throw Exception('Tipe tabel tidak dikenali');
    }

    try {
      final response = await http.get(Uri.parse(url));
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
        throw Exception('Terjadi kesalahan saat mengambil data');
      }
    }
  }

  String generateHtmlTable(data) {
    var html = '''
    <table border="1" style="width: 100%; border-collapse: collapse; font-family: 'Plus Jakarta Sans', sans-serif; font-size: 12px; border: 1px solid #E2E8F0;">
      <thead>
        <tr style="background-color: #002B6A; color: white;">
          <th rowspan="3" style="border: 1px solid #1E3A8A; padding: 10px 12px; text-align: center; font-weight: 700;">${data['labelvervar']}</th>
    ''';
    final varData =
        (data["var"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final vervarData =
        (data["vervar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final turvarData =
        (data["turvar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final dataContent =
        (data["datacontent"] as Map?)?.cast<String, dynamic>() ?? {};
    final tahun =
        (data["tahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final turTahun =
        (data["turtahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            [];

    for (var varData in varData) {
      html +=
          '<th colspan="${tahun.length * turvarData.length}" style="border: 1px solid #1E3A8A; padding: 10px 12px; text-align: center; font-weight: 700;">${varData['label']}</th>';
    }
    html +=
        '</tr><tr style="background-color: #002B6A; color: white;">';

    for (var varData in varData) {
      for (var element in turvarData) {
        html +=
            '<th colspan="${tahun.length}" style="border: 1px solid #1E3A8A; padding: 10px 12px; text-align: center; font-weight: 700;">${element['label'] == 'Tidak Ada' ? 'Tahun' : element['label']}</th>';
      }
    }

    html +=
        '</tr><tr style="background-color: #002B6A; color: white;">';

    for (var varData in varData) {
      for (var _ in turvarData) {
        for (var element in tahun) {
          html +=
              '<th style="border: 1px solid #1E3A8A; padding: 10px 12px; text-align: center; font-weight: 700;">${element['label']}</th>';
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
      for (var varData in varData) {
        for (var turvar in turvarData) {
          for (var tahun in tahun) {
            final key =
                "${vervar["val"]}${varData["val"]}${turvar["val"]}${tahun['val']}${turTahun[0]['val']}";
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

  String generateCsv(data) {
    final varData =
        (data["var"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final vervarData =
        (data["vervar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final turvarData =
        (data["turvar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final dataContent =
        (data["datacontent"] as Map?)?.cast<String, dynamic>() ?? {};
    final tahun =
        (data["tahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final turTahun =
        (data["turtahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            [];

    List<List<String>> csvData = [];

    // Header
    List<String> header1 = [''];
    for (var varData in varData) {
      header1.addAll(
          List.filled(tahun.length * turvarData.length, varData['label']));
    }
    csvData.add(header1);

    List<String> header2 = [data['labelvervar']];
    for (var varData in varData) {
      for (var element in turvarData) {
        header2.addAll(List.filled(tahun.length,
            element['label'] == 'Tidak Ada' ? 'Tahun' : element['label']));
      }
    }
    csvData.add(header2);

    List<String> header3 = [''];
    for (var varData in varData) {
      for (var _ in turvarData) {
        for (var tahun in tahun) {
          header3.add(tahun['label']);
        }
      }
    }
    csvData.add(header3);

    // Rows
    for (var vervar in vervarData) {
      List<String> row = [vervar['label']];
      for (var varData in varData) {
        for (var turvar in turvarData) {
          for (var tahun in tahun) {
            final key =
                "${vervar["val"]}${varData["val"]}${turvar["val"]}${tahun['val']}${turTahun[0]['val']}";
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
                  ],
                ),
              ),
            );
          } else {
            final data = snapshot.data!;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
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
                          widget.title,
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
                          child: HtmlWidget(generateHtmlTable(data)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (data["datacontent"] != null &&
                      data["datacontent"].isNotEmpty)
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF002B6A), Color(0xFF1A5FAF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF002B6A).withOpacity(0.3),
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
                        'Hak Cipta © 2025 Badan Pusat Statistik Kabupaten Demak',
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
