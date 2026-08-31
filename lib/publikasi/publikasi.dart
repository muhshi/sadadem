import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/components/bottom_nav.dart';
import 'package:Dalem/components/home_ber.dart';
import 'package:Dalem/components/home_info.dart';
import 'package:Dalem/components/state_widgets.dart';
import 'package:Dalem/berita/berita.dart';
import 'package:Dalem/infographic/infographic.dart';
import 'package:Dalem/model/download.dart';
import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/providers/publication_provider.dart';
import 'package:Dalem/publikasi/all_publications_page.dart';
import 'package:Dalem/publikasi/detail_publikasi.dart';
import 'package:Dalem/main_screen.dart';
import 'package:Dalem/utils/page_transitions.dart';

class Publikasi extends StatefulWidget {
  final bool showBottomNav;
  const Publikasi({super.key, this.showBottomNav = true});

  @override
  PublikasiState createState() => PublikasiState();
}

class PublikasiState extends State<Publikasi>
    with AutomaticKeepAliveClientMixin {
  int _refreshKey = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PublicationProvider>(context, listen: false)
          .fetchPublications();
    });
  }

  Future<void> _handleRefresh() async {
    await Provider.of<PublicationProvider>(context, listen: false)
        .refreshPublications();
    if (mounted) {
      setState(() {
        _refreshKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
        appBar: const AppBar2(
          title: 'Publikasi & Media Rilis',
          showBackButton: false,
        ),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primaryNavy,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 📚 Section 1: Publikasi Terbaru
                _buildPublicationsSection(),

                const SizedBox(height: 16),

                // 2. 📊 Section 2: Informasi & Infografis Terbaru
                HomeInfo(
                  key: ValueKey('pub_info_$_refreshKey'),
                  title: 'Informasi & Infografis',
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      SmoothPageRoute(
                        child: const Infographic(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 3. 📰 Section 3: Berita Kegiatan BPS
                Homeberita(
                  key: ValueKey('pub_berita_$_refreshKey'),
                  title: 'Berita & Rilis BPS',
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      SmoothPageRoute(
                        child: const Berita(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 4. ⚡ Quick Action Shortcuts
                _buildQuickActions(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        bottomNavigationBar: widget.showBottomNav
            ? const BottomNav(currentIndex: 2)
            : null,
      );
  }

  Widget _buildPublicationsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Publikasi Terbaru',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      SmoothPageRoute(
                        child: const AllPublicationsPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Semua',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.linkAction,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: AppColors.linkAction,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Content List (Limited to 3 latest)
            Consumer<PublicationProvider>(
              builder: (context, provider, child) {
                if (provider.isInitialLoading) {
                  return _buildShimmerLoading();
                }

                if (provider.isError && provider.publications.isEmpty) {
                  return ErrorStateWidget(
                    title: 'Gagal Memuat Publikasi',
                    message: 'Silakan periksa koneksi internet Anda.',
                    isCompact: true,
                    onRetry: _handleRefresh,
                  );
                }

                if (provider.publications.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'Belum Ada Publikasi',
                    message: 'Data publikasi terbaru akan muncul di sini.',
                    icon: Icons.menu_book_outlined,
                  );
                }

                // Show top 3 publications
                final items = provider.publications.take(3).toList();

                return Column(
                  children: [
                    ...items.map((item) => _buildPublicationItem(item)),
                    const SizedBox(height: 8),
                    // Full List Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            SmoothPageRoute(
                              child: const AllPublicationsPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          side: const BorderSide(
                              color: Color(0xFFCBD5E1), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color(0xFFF8FAFC),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Buka Semua Publikasi BPS Demak',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Color(0xFF334155),
                            ),
                          ],
                        ),
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

  Widget _buildPublicationItem(Map<String, dynamic> item) {
    final title = item['title'] ?? 'Publikasi BPS';
    final coverUrl = item['cover'] ?? '';
    final releaseDate = item['rl_date'] ?? 'No Date';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPublikasi(publication: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: coverUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: coverUrl,
                          width: 58,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              width: 58,
                              height: 80,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 58,
                            height: 80,
                            color: const Color(0xFFE2E8F0),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Color(0xFF94A3B8),
                              size: 24,
                            ),
                          ),
                        )
                      : Container(
                          width: 58,
                          height: 80,
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFF94A3B8),
                            size: 24,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Title & Metadata
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 10.5,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  releaseDate,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Lihat Dokumen',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: AppColors.primaryNavy,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionTile(
              title: 'Cari Dokumen',
              subtitle: 'Katalog Publikasi',
              icon: Icons.search_rounded,
              color: const Color(0xFF2563EB),
              onTap: () {
                Navigator.push(
                  context,
                  SmoothPageRoute(
                    child: const SearchPage(autofocus: true),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionTile(
              title: 'Dokumen Diunduh',
              subtitle: 'Baca Offline',
              icon: Icons.download_done_rounded,
              color: const Color(0xFF059669),
              onTap: () {
                Navigator.push(
                  context,
                  SmoothPageRoute(
                    child: const DownloadedPublicationsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
