import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Dalem/cat/catdetail.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/components/bottom_nav.dart';
import 'package:Dalem/utils/page_transitions.dart';

class SubCategoryListPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> staticData;
  final List<Color> gradientColors;
  final Color categoryColor;

  const SubCategoryListPage({
    super.key,
    required this.title,
    required this.staticData,
    required this.gradientColors,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar2(
        title: title,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: staticData.length,
        itemBuilder: (context, index) {
          var item = staticData[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSubCategoryCard(
              icon: item['icon'] as IconData? ?? Icons.folder_rounded,
              title: item['title'],
              gradientColors: gradientColors,
              onTap: () {
                Navigator.push(
                  context,
                  SmoothPageRoute(
                    child: Catdetail(
                      id: item['sub_id'],
                      title: item['title'],
                      color: categoryColor,
                      desc: 'Description for ${item['title']}',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildSubCategoryCard({
    required IconData icon,
    required String title,
    required List<Color> gradientColors,
    required VoidCallback onTap,
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
            color: gradientColors.last.withValues(alpha: 0.2),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
