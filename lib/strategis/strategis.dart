import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/table/table.dart';
import 'package:Dalem/components/offline_storage.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/config/api_config.dart';
import 'package:Dalem/components/state_widgets.dart';

Future<Map<String, dynamic>> fetchData(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      await OfflineStorage.saveData(url, jsonResponse);
      return jsonResponse;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    final offlineData = await OfflineStorage.loadData(url);
    if (offlineData != null) {
      return offlineData;
    } else {
      throw Exception('Failed to load data and no offline data available');
    }
  }
}

class Strategis extends StatefulWidget {
  final String title;
  final Color color;

  const Strategis({super.key, required this.title, required this.color});

  @override
  _StrategisState createState() => _StrategisState();
}

class _StrategisState extends State<Strategis> {
  late Future<dynamic> _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dataFuture = fetchData(
      ApiConfig.listUrl(model: 'tablestatistic', keyword: 'strategis'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar2(
        title: widget.title,
      ),
      body: FutureBuilder<dynamic>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return ErrorStateWidget(
              title: 'Gagal Memuat Indikator Strategis',
              message: 'Tidak dapat mengambil data indikator strategis dari server.',
              onRetry: () {
                setState(() {
                  _loadData();
                });
              },
            );
          } else if (!snapshot.hasData || snapshot.data!['data'] == null || snapshot.data!['data'][1] == null) {
            return const EmptyStateWidget(
              title: 'Data Strategis Kosong',
              message: 'Belum ada indikator strategis yang tersedia.',
            );
          } else {
            final items = snapshot.data!['data'][1] as List<dynamic>;
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                var item = items[index];
                var decodedId = utf8.decode(base64.decode(item['id'].toString()));
                var arrayId = decodedId.split('#');
                var id = arrayId[0];

                var titleParts = item['title'].split('Strategis] ');
                var title = titleParts.length > 1 ? titleParts[1] : item['title'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildStatisticCategory(
                    title: title,
                    id: id,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DataTableScreen(
                          id: id,
                          title: title,
                          tableType: '2',
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildStatisticCategory({
    required String id,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFE2E8F0),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<String>(
                        future: fetchDescription(id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Shimmer.fromColors(
                              baseColor: Colors.white10,
                              highlightColor: Colors.white24,
                              child: Container(
                                width: 140,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              '-',
                              style: GoogleFonts.plusJakartaSans(color: Colors.white70),
                            );
                          } else {
                            final data = snapshot.data ?? 'Tidak tersedia';
                            return Text(
                              data,
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFD4A843), // Gold accent
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> fetchDescription(String id) async {
    try {
      final response = await fetchData(ApiConfig.dataUrl(varId: id));
      final data = response ?? {};
      final vervarData = data["vervar"] ?? [];
      final varData = data["var"] ?? [];
      final turvarData = data["turvar"] ?? [];
      final dataContent = data["datacontent"] ?? {} as Map<String, dynamic>;
      final tahun = data["tahun"] ?? [];
      final turTahun = data["turtahun"] ?? [];

      var unit = varData[varData.length - 1]["unit"] ?? '';
      var key =
          '${vervarData[vervarData.length - 1]["val"]}${varData[varData.length - 1]["val"]}${turvarData[turvarData.length - 1]["val"]}${tahun[tahun.length - 1]["val"]}${turTahun[turTahun.length - 1]["val"]}';
      var resValue = "${dataContent[key]} $unit".replaceAll('.', ',');
      if (!resValue.contains(',')) {
        resValue = resValue.replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
      }

      var resTahun = tahun[tahun.length - 1]["label"];
      return '$resValue ($resTahun)';
    } catch (e) {
      return 'Tidak tersedia';
    }
  }
}
