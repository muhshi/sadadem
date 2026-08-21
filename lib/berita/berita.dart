import 'dart:convert';
import 'package:Dalem/berita/detail_berita.dart';
import 'package:Dalem/components/bottom_nav.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Dalem/config/api_config.dart';
import 'package:Dalem/utils/page_transitions.dart';

class Berita extends StatefulWidget {
  const Berita({super.key});

  @override
  BeritaState createState() => BeritaState();
}

class BeritaState extends State<Berita> {
  late ScrollController _scrollController;
  List<dynamic> beritaList = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    fetchBerita();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMoreData) {
      fetchBerita();
    }
  }

  Future<void> fetchBerita() async {
    setState(() {
      isLoading = true;
    });

    final url = ApiConfig.listUrl(model: 'news', page: currentPage, perpage: 10);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final newBerita = jsonResponse['data'][1];

      if (mounted) {
        setState(() {
          beritaList.addAll(newBerita);
          currentPage++;
          isLoading = false;
          hasMoreData = newBerita.length == 10;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      currentPage = 1;
      beritaList = [];
      hasMoreData = true;
    });
    await fetchBerita();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: const AppBar2(
        title: 'Berita Kegiatan BPS',
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primaryNavy,
        backgroundColor: Colors.white,
        child: beritaList.isEmpty && isLoading
            ? GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
              )
            : GridView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(12.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: beritaList.length + (hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == beritaList.length) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  }
                  var item = beritaList[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            SmoothPageRoute(
                              child: DetailBerita(
                                  newsId: item['news_id'].toString()),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: item['picture'] != null &&
                                          item['picture'].isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: item['picture'],
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                            baseColor: Colors.grey.shade200,
                                            highlightColor: Colors.grey.shade100,
                                            child: Container(
                                              color: Colors.white,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: Colors.grey.shade100,
                                            child: const Icon(
                                                Icons.broken_image_rounded,
                                                color: Colors.grey),
                                          ),
                                        )
                                      : Container(color: Colors.grey.shade100),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (item['rl_date'] != null)
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded,
                                        size: 10, color: Color(0xFF64748B)),
                                    const SizedBox(width: 4),
                                    Text(
                                      item['rl_date'],
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              Text(
                                HtmlUnescape()
                                    .convert(item['title'] ?? 'No Title'),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}
