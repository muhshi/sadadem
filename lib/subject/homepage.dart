import 'package:Dalem/berita/berita.dart';
import 'package:Dalem/components/home_ber.dart';
import 'package:Dalem/components/home_info.dart';
import 'package:Dalem/components/bottom_nav.dart';
import 'package:Dalem/subcat/ekonomi.dart';
import 'package:Dalem/subcat/lingkungan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bps_theme.dart';
import 'package:Dalem/components/appbar.dart';
import 'package:Dalem/config/api_config.dart';
import 'package:Dalem/components/home_pub.dart';
import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/strategis/strategis.dart';
import 'package:Dalem/subcat/demografi.dart';
import 'package:Dalem/infographic/infographic.dart';
import 'package:url_launcher/url_launcher.dart';

class Homepage extends StatefulWidget {
  final bool showBottomNav;
  const Homepage({super.key, this.showBottomNav = true});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<Map<String, dynamic>> staticData = const [
    {"subcat_id": 514, "title": "Statistik Demografi dan Sosial"},
    {"subcat_id": 516, "title": "Statistik Lingkungan Hidup dan Multi-domain"},
    {"subcat_id": 515, "title": "Statistik Ekonomi"}
  ];

  List<Map<String, dynamic>> homeListData = [];
  bool isLoadingHomeData = false;

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
      final response = await http.get(Uri.parse(
          ApiConfig.listUrl(model: 'publication', perpage: 4)));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            homeListData =
                List<Map<String, dynamic>>.from(data['data'][1]).take(1).toList();
            isLoadingHomeData = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoadingHomeData = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingHomeData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      body: RefreshIndicator(
        onRefresh: fetchHomeListData,
        color: AppColors.primaryNavy,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const CustomAppBar(),
                  // Search Bar Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryNavy.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SearchPage(
                                        autofocus: true,
                                      )),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryNavy.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: AppColors.primaryNavy,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Cari data statistik, publikasi, dll...',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Cari',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF64748B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                                    MaterialPageRoute(
                                      builder: (context) => Strategis(
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
                                    MaterialPageRoute(
                                      builder: (context) => ListDetail514(
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
                                    MaterialPageRoute(
                                      builder: (context) => ListDetail516(
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
                                    MaterialPageRoute(
                                      builder: (context) => ListDetail515(
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
                        MaterialPageRoute(
                          builder: (context) => const Publikasi(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  HomeInfo(
                    title: 'Informasi Terbaru',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Infographic(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Homeberita(
                    title: 'Berita Kegiatan BPS',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Berita(),
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
                          'Hak Cipta © 2025 Badan Pusat Statistik Kabupaten Demak',
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
}
