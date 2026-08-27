import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bps_theme.dart';
import 'package:Dalem/table/table.dart';
import 'package:Dalem/config/api_config.dart';
import 'package:Dalem/services/bps_api_service.dart';
import 'package:Dalem/about/about_page.dart';
import 'package:Dalem/utils/page_transitions.dart';

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
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/img/homei.png',
                            height: 44,
                            errorBuilder: (context, error, stackTrace) => Text(
                              'BPS KABUPATEN DEMAK',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.campaign_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  BpsTheme.current().activityName,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            tooltip: 'Tentang Aplikasi',
                            onPressed: () {
                              Navigator.push(
                                context,
                                SmoothPageRoute(
                                  child: const AboutPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
                  future: BpsApiService.fetchJson(
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
                          color: const Color(0xFF0F172A),
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
      final response =
          await BpsApiService.fetchJson(ApiConfig.dataUrl(varId: id));
      final data = response;
      final vervarData = (data["vervar"] as List<dynamic>?) ?? [];
      final varData = (data["var"] as List<dynamic>?) ?? [];
      final turvarData = (data["turvar"] as List<dynamic>?) ?? [];
      final dataContent = (data["datacontent"] is Map)
          ? (data["datacontent"] as Map)
          : <String, dynamic>{};
      final tahun = (data["tahun"] as List<dynamic>?) ?? [];
      final turTahun = (data["turtahun"] as List<dynamic>?) ?? [];

      if (varData.isEmpty || vervarData.isEmpty || tahun.isEmpty) {
        return 'Data belum tersedia';
      }

      final unit = varData.last["unit"]?.toString() ?? '';
      final turVarVal = turvarData.isNotEmpty ? turvarData.last["val"] : 0;
      final turTahunVal = turTahun.isNotEmpty ? turTahun.last["val"] : 0;
      final key =
          '${vervarData.last["val"]}${varData.last["val"]}$turVarVal${tahun.last["val"]}$turTahunVal';

      final rawVal = dataContent[key];
      if (rawVal == null || rawVal.toString() == '-') {
        return 'Data belum tersedia';
      }

      var resValue = "$rawVal $unit".replaceAll('.', ',');
      if (!resValue.contains(',')) {
        resValue = resValue.replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
      }

      var resTahun = tahun.last["label"]?.toString() ?? '';
      return '$resValue ($resTahun)';
    } catch (e) {
      return 'Data belum tersedia';
    }
  }
}
