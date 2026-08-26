import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/appbar.dart';
import 'package:Dalem/components/bottom_nav.dart';
import 'package:Dalem/components/home_ber.dart';
import 'package:Dalem/components/home_info.dart';
import 'package:Dalem/components/home_pub.dart';
import 'package:Dalem/components/bps_theme.dart';
import 'package:Dalem/berita/berita.dart';
import 'package:Dalem/infographic/infographic.dart';
import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/publikasi/all_publications_page.dart';
import 'package:Dalem/strategis/strategis.dart';
import 'package:Dalem/subcat/demografi.dart';
import 'package:Dalem/subcat/lingkungan.dart';
import 'package:Dalem/subcat/ekonomi.dart';
import 'package:Dalem/config/api_config.dart';
import 'package:Dalem/services/bps_api_service.dart';
import 'package:Dalem/utils/page_transitions.dart';

class Homepage extends StatefulWidget {
  final bool showBottomNav;
  const Homepage({super.key, this.showBottomNav = true});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Map<String, dynamic>> homeListData = [];
  bool isLoadingHomeData = true;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    fetchHomeListData();
  }

  Future<void> fetchHomeListData() async {
    setState(() {
      isLoadingHomeData = true;
    });
    try {
      final list = await BpsApiService.fetchDataList(
          ApiConfig.listUrl(model: 'publication', perpage: 4));

      if (mounted) {
        setState(() {
          homeListData = list.take(1).map((e) => Map<String, dynamic>.from(e)).toList();
          isLoadingHomeData = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingHomeData = false);
    }
  }

  Future<void> _handleFullRefresh() async {
    setState(() {
      _refreshKey++;
    });
    await fetchHomeListData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      body: RefreshIndicator(
        onRefresh: _handleFullRefresh,
        color: AppColors.primaryNavy,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  CustomAppBar(key: ValueKey('appbar_$_refreshKey')),
                  // 🔍 Redesigned Prominent Search Bar Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: AppColors.primaryNavy.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              SmoothPageRoute(
                                child: const SearchPage(autofocus: true),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: AppColors.primaryNavy,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Cari data statistik Demak...',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF1E293B),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Inflasi, Kemiskinan, PDRB, Penduduk...',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFF94A3B8),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryNavy,
                                    borderRadius: BorderRadius.circular(11),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryNavy.withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Cari',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 🏷️ Quick Search Chips (Popular shortcut tags)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(right: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  size: 14,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Populer:',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildQuickTopicChip('Inflasi'),
                          _buildQuickTopicChip('Kemiskinan'),
                          _buildQuickTopicChip('Jumlah Penduduk'),
                          _buildQuickTopicChip('PDRB'),
                          _buildQuickTopicChip('Pertanian'),
                          _buildQuickTopicChip('Ketenagakerjaan'),
                        ],
                      ),
                    ),
                  ),

                  // Header Category Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
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
                          'KATEGORI STATISTIK',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category Cards (Grid 2x2)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Row 1: Data Strategis & Demografi
                        Row(
                          children: [
                            Expanded(
                              child: _buildGridCategoryCard(
                                title: 'Data Strategis',
                                subtitle: 'Indikator Utama',
                                gradientColors: BpsTheme.current().cardGradient1,
                                icon: Icons.insights_rounded,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SmoothPageRoute(
                                      child: Strategis(
                                        title: 'Data Strategis',
                                        color: BpsTheme.current().cardGradient1.first,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGridCategoryCard(
                                title: 'Demografi & Sosial',
                                subtitle: '11 Subjek Data',
                                gradientColors: BpsTheme.current().cardGradient2,
                                icon: Icons.people_alt_rounded,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SmoothPageRoute(
                                      child: ListDetail514(
                                        id: 514,
                                        title: 'Statistik Demografi dan Sosial',
                                        color: BpsTheme.current().cardGradient2.first,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Row 2: Lingkungan Hidup & Ekonomi
                        Row(
                          children: [
                            Expanded(
                              child: _buildGridCategoryCard(
                                title: 'Lingkungan Hidup',
                                subtitle: '11 Subjek Data',
                                gradientColors: BpsTheme.current().cardGradient3,
                                icon: Icons.forest_rounded,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SmoothPageRoute(
                                      child: ListDetail516(
                                        id: 516,
                                        title: 'Statistik Lingkungan Hidup dan Multi-domain',
                                        color: BpsTheme.current().cardGradient3.first,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGridCategoryCard(
                                title: 'Ekonomi',
                                subtitle: '15 Subjek Data',
                                gradientColors: BpsTheme.current().cardGradient4,
                                icon: Icons.payments_rounded,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SmoothPageRoute(
                                      child: ListDetail515(
                                        id: 515,
                                        title: 'Statistik Ekonomi',
                                        color: BpsTheme.current().cardGradient4.first,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  HomePublication(
                    title: 'Publikasi Terbaru',
                    data: homeListData,
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        SmoothPageRoute(
                          child: const AllPublicationsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  HomeInfo(
                    key: ValueKey('info_$_refreshKey'),
                    title: 'Informasi Terbaru',
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
                  Homeberita(
                    key: ValueKey('berita_$_refreshKey'),
                    title: 'Berita Kegiatan BPS',
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
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
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
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? const BottomNav(currentIndex: 0)
          : null,
    );
  }

  Widget _buildGridCategoryCard({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.22),
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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTopicChip(String topic) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              SmoothPageRoute(
                child: SearchPage(
                  autofocus: false,
                  initialQuery: topic,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              topic,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
