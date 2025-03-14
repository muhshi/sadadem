import 'package:Dalem/components/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:Dalem/cat/catdetail.dart';
import 'package:Dalem/components/bar.dart';

class ListDetail516 extends StatelessWidget {
  final int id;
  final String title;
  final Color color;

  const ListDetail516(
      {super.key, required this.id, required this.title, required this.color});

  final List<Map<String, dynamic>> staticData = const [
  {"sub_id": 539, "subcat_id": 516, "title": "Lingkungan"},
  {"sub_id": 540, "subcat_id": 516, "title": "Statistik Regional dan Statistik Area Kecil"},
  {"sub_id": 541, "subcat_id": 516, "title": "Statistik dan Indikator Multi-Domain"},
  {"sub_id": 542, "subcat_id": 516, "title": "Buku Tahunan dan Ringkasan Sejenis"},
  {"sub_id": 563, "subcat_id": 516, "title": "Kondisi Tempat Tinggal, Kemiskinan, dan Permasalahan Sosial Lintas Sektor"},
  {"sub_id": 564, "subcat_id": 516, "title": "Gender dan Kelompok Populasi Khusus"},
  {"sub_id": 565, "subcat_id": 516, "title": "Masyarakat Informasi"},
  {"sub_id": 566, "subcat_id": 516, "title": "Globalisasi"},
  {"sub_id": 567, "subcat_id": 516, "title": "Indikator Millenium Development Goals (MDGs)"},
  {"sub_id": 568, "subcat_id": 516, "title": "Perkembangan Berkelanjutan"},
  {"sub_id": 569, "subcat_id": 516, "title": "Kewiraswastaan"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar2(
        title: title,
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: staticData.length,
                  itemBuilder: (context, index) {
                    var item = staticData[index];

                    return _buildStatisticCategory(
                      icon: Icons.folder_copy_outlined,
                      title: item['title'],
                      color: color,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Catdetail(
                                  id: item['sub_id'],
                                  title: item['title'],
                                  color: color,
                                  desc: 'Description for ${item['title']}')),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom navigation tap if needed
        },
      ),
    );
  }

  Widget _buildStatisticCategory({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 25),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
