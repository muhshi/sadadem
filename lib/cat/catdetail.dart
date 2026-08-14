import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/table/table.dart' as Dalem_table;
import 'package:Dalem/components/offline_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Dalem/config/api_config.dart';
import 'package:Dalem/components/state_widgets.dart';

class Catdetail extends StatefulWidget {
  final String title;
  final int id;
  final String desc;
  final Color color;

  const Catdetail({
    super.key,
    this.id = 0,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  State<Catdetail> createState() => _CatdetailState();
}

class _CatdetailState extends State<Catdetail> {
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dataFuture = fetchData(
      ApiConfig.listUrl(model: 'tablestatistic', page: 1, perpage: 200) +
          'subject/${widget.id}/',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar2(
        title: widget.title,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 80,
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
              title: 'Gagal Memuat Tabel Statistik',
              message: 'Terjadi masalah saat mengambil data tabel dari server.',
              onRetry: () {
                setState(() {
                  _loadData();
                });
              },
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(
              title: 'Tabel Belum Tersedia',
              message: 'Belum ada data tabel statistik untuk kategori ini.',
            );
          } else {
            // Filter and sort data
            var filteredData = snapshot.data!
                .where((item) =>
                    item['last_update'] != null &&
                    item['last_update'].toString().isNotEmpty)
                .toList();

            filteredData.sort(
                (a, b) => b['last_update'].compareTo(a['last_update']));

            if (filteredData.isEmpty) {
              return const EmptyStateWidget(
                title: 'Tabel Belum Tersedia',
                message: 'Belum ada data tabel statistik terbarui untuk kategori ini.',
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                var item = filteredData[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildStatisticCategory(
                    icon: Icons.table_chart_rounded,
                    title: item['title'],
                    lastUpdate: item['last_update'],
                    onTap: () {
                      var decodedId = utf8.decode(base64.decode(item['id'].toString()));
                      var arrayId = decodedId.split('#');
                      var id = arrayId[0];
                      var tableType = arrayId.length > 1 ? arrayId[1] : '1';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Dalem_table.DataTableScreen(
                            id: id,
                            title: item['title'],
                            tableType: tableType,
                          ),
                        ),
                      );
                    },
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
    required IconData icon,
    required String title,
    required String lastUpdate,
    required VoidCallback onTap,
  }) {
    final primaryNavy = AppColors.primaryNavy;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primaryNavy, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      if (lastUpdate.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.history_rounded, size: 12, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text(
                              'Diperbarui: $lastUpdate',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF94A3B8),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body)['data'][1];
        await OfflineStorage.saveData(url, jsonResponse);
        return jsonResponse;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      final offlineData = await OfflineStorage.loadData(url);
      if (offlineData != null) {
        return offlineData as List<dynamic>;
      } else {
        throw Exception('Failed to load data and no offline data available');
      }
    }
  }
}
