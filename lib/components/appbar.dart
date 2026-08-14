import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/table/table.dart';
import 'package:Dalem/components/offline_storage.dart';
import 'package:Dalem/config/api_config.dart';

Future<Map<String, dynamic>> fetchData(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Save data offline
      await OfflineStorage.saveData(url, jsonResponse);
      return jsonResponse;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    // Load data from offline storage if API call fails
    final offlineData = await OfflineStorage.loadData(url);
    if (offlineData != null) {
      return offlineData;
    } else {
      throw Exception('Failed to load data and no offline data available');
    }
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              AppColors.primaryNavy,
              AppColors.primaryLight,
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Image.asset(
                    'assets/img/homei.png',
                    height: 55,
                    errorBuilder: (context, error, stackTrace) => Text(
                      'BPS KABUPATEN DEMAK',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A843),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'INDIKATOR STRATEGIS KABUPATEN DEMAK',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<dynamic>(
                  future: fetchData(
                      ApiConfig.listUrl(model: 'tablestatistic', keyword: 'strategis')),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CarouselSlider.builder(
                        options: CarouselOptions(
                          height: 130,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 5),
                          enlargeCenterPage: true,
                          viewportFraction: 0.88,
                        ),
                        itemCount: 3,
                        itemBuilder: (context, index, realIndex) {
                          return Shimmer.fromColors(
                            baseColor: Colors.white.withValues(alpha: 0.1),
                            highlightColor: Colors.white.withValues(alpha: 0.25),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Gagal memuat indikator',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!['data'][1] == null) {
                      return Center(
                        child: Text(
                          'Data tidak tersedia',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
                        ),
                      );
                    } else {
                      final items = snapshot.data!['data'][1] as List<dynamic>;
                      return CarouselSlider(
                        options: CarouselOptions(
                          height: 130,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 4),
                          enlargeCenterPage: true,
                          viewportFraction: 0.88,
                        ),
                        items: items.map<Widget>((item) {
                          var decodedId = utf8.decode(base64.decode(item['id'].toString()));
                          var arrayId = decodedId.split('#');
                          var id = arrayId[0];

                          var titleParts = item['title'].split('Strategis] ');
                          var title = titleParts.length > 1 ? titleParts[1] : item['title'];
                          return _buildStatisticCategory(
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
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(230.0);

  Widget _buildStatisticCategory({
    required String title,
    required String id,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                FutureBuilder<String>(
                  future: fetchDescription(id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 120,
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
                        style: GoogleFonts.plusJakartaSans(color: Colors.red),
                      );
                    } else {
                      final data = snapshot.data ?? 'Memuat...';
                      return Text(
                        data,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primaryNavy,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    }
                  },
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
      final data = response;
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
      return 'Data belum tersedia';
    }
  }
}
