import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:shimmer/shimmer.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:Dalem/config/api_config.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/full_screen_image_viewer.dart';
import 'package:Dalem/components/state_widgets.dart';
import 'package:Dalem/services/bps_api_service.dart';
import 'package:Dalem/utils/page_transitions.dart';

class HomeInfo extends StatefulWidget {
  final String title;
  final Function() onSeeAll;

  const HomeInfo({super.key, required this.title, required this.onSeeAll});

  @override
  HomeInfoState createState() => HomeInfoState();
}

class HomeInfoState extends State<HomeInfo> {
  late Future<List<dynamic>> futureBerita;

  @override
  void initState() {
    super.initState();
    futureBerita = fetchBerita();
  }

  Future<List<dynamic>> fetchBerita() async {
    try {
      final list = await BpsApiService.fetchDataList(
          ApiConfig.listUrl(model: 'infographic'));
      if (list.isNotEmpty) {
        return [list[0]];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryNavy = AppColors.primaryNavy;

    return FutureBuilder<List<dynamic>>(
      future: futureBerita,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 250,
                color: Colors.white,
              ),
            ),
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ErrorStateWidget(
              isCompact: true,
              title: 'Gagal Memuat Infografis',
              message: 'Tidak dapat terhubung ke server infografis.',
              onRetry: () {
                setState(() {
                  futureBerita = fetchBerita();
                });
              },
            ),
          );
        } else {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF14B8A6), // Teal accent for Infographics
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: widget.onSeeAll,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Lihat Semua',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: primaryNavy),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data![index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: GestureDetector(
                              onTap: () {
                                FullScreenImageViewer.show(context, item['img']);
                              },
                              child: CachedNetworkImage(
                                imageUrl: item['img'],
                                width: double.infinity,
                                height: 320,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    width: double.infinity,
                                    height: 320,
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Container(
                                  height: 200,
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: Icon(Icons.broken_image_rounded,
                                        color: Colors.grey, size: 40),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                item['date'] ?? 'No Date',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          HtmlWidget(
                            HtmlUnescape().convert(item['title'] ?? 'No Title'),
                            textStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
