import 'package:flutter/material.dart';
import 'package:Dalem/subcat/subcat_page.dart';

class ListDetail514 extends StatelessWidget {
  final int id;
  final String title;
  final Color color;

  const ListDetail514({
    super.key,
    required this.id,
    required this.title,
    required this.color,
  });

  static const List<Map<String, dynamic>> staticData = [
    {"sub_id": 519, "subcat_id": 514, "title": "Kependudukan dan Migrasi", "icon": Icons.groups_rounded},
    {"sub_id": 520, "subcat_id": 514, "title": "Tenaga Kerja", "icon": Icons.work_rounded},
    {"sub_id": 521, "subcat_id": 514, "title": "Pendidikan", "icon": Icons.school_rounded},
    {"sub_id": 522, "subcat_id": 514, "title": "Kesehatan", "icon": Icons.medical_services_rounded},
    {"sub_id": 523, "subcat_id": 514, "title": "Konsumsi dan Pendapatan", "icon": Icons.shopping_bag_rounded},
    {"sub_id": 524, "subcat_id": 514, "title": "Perlindungan Sosial", "icon": Icons.security_rounded},
    {"sub_id": 525, "subcat_id": 514, "title": "Pemukiman dan Perumahan", "icon": Icons.home_work_rounded},
    {"sub_id": 526, "subcat_id": 514, "title": "Hukum dan Kriminal", "icon": Icons.gavel_rounded},
    {"sub_id": 527, "subcat_id": 514, "title": "Budaya", "icon": Icons.theater_comedy_rounded},
    {"sub_id": 528, "subcat_id": 514, "title": "Aktivitas Politik dan Komunitas", "icon": Icons.how_to_vote_rounded},
    {"sub_id": 529, "subcat_id": 514, "title": "Penggunaan Waktu", "icon": Icons.access_time_filled_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SubCategoryListPage(
      title: title,
      staticData: staticData,
      gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      categoryColor: color,
    );
  }
}
