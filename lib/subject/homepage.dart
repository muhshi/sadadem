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
                  // Search Bar Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
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
                                  builder: (context) => const SearchPage(
                                        autofocus: true,
                                      )),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Cari data statistik, publikasi, & berita...',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.tune_rounded, color: Color(0xFF64748B), size: 16),
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
                            color: const Color(0xFF002B6A),
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

                  // Category Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Data Strategis Card
                        _buildStatisticCategoryCard(
                          title: 'Data Strategis',
                          subtitle: 'Indikator utama statistik Kabupaten Demak',
                          gradientColors: const [Color(0xFF1E293B), Color(0xFF0F172A)],
                          icon: Icons.insights_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Strategis(
                                  title: 'Data Strategis',
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        // Static Categories
                        ...staticData.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> item = entry.value;

                          List<Color> gradientColors;
                          Color solidColor;
                          IconData icon;
                          String subtitle;

                          if (index % 3 == 0) {
                            gradientColors = const [Color(0xFF2563EB), Color(0xFF1D4ED8)];
                            solidColor = Colors.blue.shade600;
                            icon = Icons.people_alt_rounded;
                            subtitle = 'Kependudukan, tenaga kerja, pendidikan, & kesehatan';
                          } else if (index % 3 == 1) {
                            gradientColors = const [Color(0xFF0D9488), Color(0xFF0F766E)];
                            solidColor = Colors.orange.shade600;
                            icon = Icons.forest_rounded;
                            subtitle = 'Lingkungan hidup, geografi, & indikator multi-domain';
                          } else {
                            gradientColors = const [Color(0xFF7C3AED), Color(0xFF6D28D9)];
                            solidColor = Colors.green.shade600;
                            icon = Icons.payments_rounded;
                            subtitle = 'Makroekonomi, neraca, perdagangan, & harga';
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildStatisticCategoryCard(
                              title: item['title'],
                              subtitle: subtitle,
                              gradientColors: gradientColors,
                              icon: icon,
                              onTap: () {
                                if (item['subcat_id'] == 514) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ListDetail514(
                                        id: item['subcat_id'],
                                        title: item['title'],
                                        color: solidColor,
                                      ),
                                    ),
                                  );
                                } else if (item['subcat_id'] == 515) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ListDetail515(
                                        id: item['subcat_id'],
                                        title: item['title'],
                                        color: solidColor,
                                      ),
                                    ),
                                  );
                                } else if (item['subcat_id'] == 516) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ListDetail516(
                                        id: item['subcat_id'],
                                        title: item['title'],
                                        color: solidColor,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        }),
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

  Widget _buildStatisticCategoryCard({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.25),
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
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
