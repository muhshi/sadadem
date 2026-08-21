import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/components/bottom_nav.dart';
import 'package:Dalem/config/api_config.dart';

import 'package:Dalem/services/bps_api_service.dart';

class DetailBerita extends StatefulWidget {
  final String newsId;

  const DetailBerita({super.key, required this.newsId});

  @override
  _DetailBeritaState createState() => _DetailBeritaState();
}

class _DetailBeritaState extends State<DetailBerita> {
  late Future<Map<String, dynamic>> futureNews;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() {
    futureNews = fetchDetailBerita(widget.newsId);
  }

  Future<Map<String, dynamic>> fetchDetailBerita(String newsId) async {
    final detailUrl = ApiConfig.viewUrl(model: 'news', id: newsId);
    final response = await BpsApiService.fetchJson(detailUrl);
    if (response['data'] != null && response['data'] is Map<String, dynamic>) {
      return response['data'] as Map<String, dynamic>;
    }
    return response;
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _loadNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: const AppBar2(
        title: 'Detail Berita',
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primaryNavy,
        backgroundColor: Colors.white,
        child: FutureBuilder<Map<String, dynamic>>(
          future: futureNews,
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Terjadi kesalahan: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.accentRose,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text(
                'Data berita tidak ditemukan',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            );
          } else {
            var news = snapshot.data!;
            var relatedNews = news['related'] as List<dynamic>? ?? [];

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Article Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          HtmlUnescape().convert(news['title'] ?? 'No Title'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              news['rl_date'] ?? 'No Date',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (news['picture'] != null &&
                            news['picture'].toString().isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: CachedNetworkImage(
                              imageUrl: news['picture'],
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade200,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: double.infinity,
                                  height: 220,
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 180,
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: Icon(Icons.broken_image_rounded,
                                      color: AppColors.textMuted, size: 40),
                                ),
                              ),
                            ),
                          ),
                        if (news['picture'] != null &&
                            news['picture'].toString().isNotEmpty)
                          const SizedBox(height: 16),
                        news['news'] != null
                            ? HtmlWidget(
                                HtmlUnescape().convert(news['news'] ?? ''),
                                textStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  height: 1.6,
                                ),
                              )
                            : Text(
                                'Konten tidak tersedia',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      ],
                    ),
                  ),

                  // Related News Section
                  if (relatedNews.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.accentRose,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Berita Terkait',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: relatedNews.length,
                      itemBuilder: (context, index) {
                        var related = relatedNews[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppColors.cardShadow,
                            border: Border.all(color: AppColors.borderDefault),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailBerita(
                                        newsId: related['news_id'].toString()),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: related['picture'] != null &&
                                              related['picture']
                                                  .toString()
                                                  .isNotEmpty
                                          ? Image.network(
                                              related['picture'],
                                              width: 65,
                                              height: 65,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                width: 65,
                                                height: 65,
                                                color: Colors.grey.shade100,
                                                child: const Icon(
                                                    Icons.broken_image_rounded,
                                                    color: AppColors.textMuted),
                                              ),
                                            )
                                          : Container(
                                              width: 65,
                                              height: 65,
                                              color: Colors.grey.shade100,
                                              child: const Icon(
                                                  Icons.newspaper_rounded,
                                                  color: AppColors.textMuted),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            HtmlUnescape().convert(
                                                related['title'] ?? 'No Title'),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today_rounded,
                                                size: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                related['rl_date'] ?? '',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  color: AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          }
        },
      ),
    ),
    floatingActionButton: FutureBuilder<Map<String, dynamic>>(
        future: futureNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return FloatingActionButton.extended(
              onPressed: () async {
                var news = snapshot.data!;
                final title = news['title'] ?? 'No Title';
                final date = news['rl_date'] ?? 'No Date';
                final document = HtmlUnescape().convert(news['news'] ?? '');
                final isi = document.replaceAll(RegExp(r'<[^>]*>'), '\n');
                var urlDate = date.replaceAll('-', '/');
                final url =
                    'https://demakkab.bps.go.id/id/news/$urlDate/${news['news_id']}';
                final picture = news['picture'] ?? '';

                if (picture.isNotEmpty) {
                  try {
                    final uri = Uri.parse(picture);
                    final response = await http.get(uri);
                    final bytes = response.bodyBytes;
                    final tempDir = await getTemporaryDirectory();
                    final file =
                        await File('${tempDir.path}/image.png').create();
                    await file.writeAsBytes(bytes);
                    var xfile = XFile(file.path);
                    await Share.shareXFiles(
                      [xfile],
                      text: '$title\n$isi\n$url',
                      subject: 'Berita BPS Demak',
                    );
                  } catch (e) {
                    await Share.share('$title\n\n$date\n\n$url');
                  }
                } else {
                  await Share.share('$title\n\n$date\n\n$url');
                }
              },
              backgroundColor: AppColors.primaryLight,
              elevation: 4,
              icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
              label: Text(
                'Bagikan',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 24,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
