import 'package:flutter/material.dart';
import 'package:Dalem/components/bps_theme.dart';
import 'package:Dalem/subcat/subcat_page.dart';

class ListDetail516 extends StatelessWidget {
  final int id;
  final String title;
  final Color color;

  const ListDetail516({
    super.key,
    required this.id,
    required this.title,
    required this.color,
  });

  static const List<Map<String, dynamic>> staticData = [
    {"sub_id": 539, "subcat_id": 516, "title": "Lingkungan Hidup", "icon": Icons.eco_rounded},
    {"sub_id": 540, "subcat_id": 516, "title": "Statistik Regional & Area Kecil", "icon": Icons.map_rounded},
    {"sub_id": 541, "subcat_id": 516, "title": "Indikator Multi-Domain", "icon": Icons.dashboard_customize_rounded},
    {"sub_id": 542, "subcat_id": 516, "title": "Buku Tahunan & Ringkasan", "icon": Icons.auto_stories_rounded},
    {"sub_id": 563, "subcat_id": 516, "title": "Kemiskinan & Tempat Tinggal", "icon": Icons.night_shelter_rounded},
    {"sub_id": 564, "subcat_id": 516, "title": "Gender & Populasi Khusus", "icon": Icons.wc_rounded},
    {"sub_id": 565, "subcat_id": 516, "title": "Masyarakat Informasi & TIK", "icon": Icons.devices_rounded},
    {"sub_id": 566, "subcat_id": 516, "title": "Globalisasi", "icon": Icons.public_rounded},
    {"sub_id": 567, "subcat_id": 516, "title": "Indikator MDGs", "icon": Icons.track_changes_rounded},
    {"sub_id": 568, "subcat_id": 516, "title": "Pembangunan Berkelanjutan (SDGs)", "icon": Icons.nature_people_rounded},
    {"sub_id": 569, "subcat_id": 516, "title": "Kewirausahaan", "icon": Icons.business_center_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SubCategoryListPage(
      title: title,
      staticData: staticData,
      gradientColors: BpsTheme.current().cardGradient3,
      categoryColor: color,
    );
  }
}
