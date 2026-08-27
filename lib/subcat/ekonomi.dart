import 'package:flutter/material.dart';
import 'package:Dalem/components/bps_theme.dart';
import 'package:Dalem/subcat/subcat_page.dart';

class ListDetail515 extends StatelessWidget {
  final int id;
  final String title;
  final Color color;

  const ListDetail515({
    super.key,
    required this.id,
    required this.title,
    required this.color,
  });

  static const List<Map<String, dynamic>> staticData = [
    {"sub_id": 530, "subcat_id": 515, "title": "Statistik Makroekonomi", "icon": Icons.show_chart_rounded},
    {"sub_id": 531, "subcat_id": 515, "title": "Neraca Ekonomi", "icon": Icons.account_balance_rounded},
    {"sub_id": 534, "subcat_id": 515, "title": "Keuangan Pemerintah & Fiskal", "icon": Icons.account_balance_wallet_rounded},
    {"sub_id": 536, "subcat_id": 515, "title": "Harga-Harga & Inflasi", "icon": Icons.sell_rounded},
    {"sub_id": 537, "subcat_id": 515, "title": "Biaya Tenaga Kerja", "icon": Icons.payments_rounded},
    {"sub_id": 538, "subcat_id": 515, "title": "IPTEK & Inovasi", "icon": Icons.lightbulb_rounded},
    {"sub_id": 557, "subcat_id": 515, "title": "Pertanian, Kehutanan, Perikanan", "icon": Icons.agriculture_rounded},
    {"sub_id": 558, "subcat_id": 515, "title": "Energi", "icon": Icons.bolt_rounded},
    {"sub_id": 559, "subcat_id": 515, "title": "Pertambangan & Konstruksi", "icon": Icons.precision_manufacturing_rounded},
    {"sub_id": 560, "subcat_id": 515, "title": "Transportasi", "icon": Icons.directions_bus_rounded},
    {"sub_id": 561, "subcat_id": 515, "title": "Pariwisata", "icon": Icons.attractions_rounded},
    {"sub_id": 562, "subcat_id": 515, "title": "Perbankan & Finansial", "icon": Icons.account_balance_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SubCategoryListPage(
      title: title,
      staticData: staticData,
      gradientColors: BpsTheme.current().cardGradient4,
      categoryColor: color,
    );
  }
}
