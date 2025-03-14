import 'package:Dalem/components/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:Dalem/cat/catdetail.dart';
import 'package:Dalem/components/bar.dart';

class ListDetail514 extends StatelessWidget {
  final int id;
  final String title;
  final Color color;

  const ListDetail514(
      {super.key, required this.id, required this.title, required this.color});

  final List<Map<String, dynamic>> staticData = const [
  {"sub_id": 519, "subcat_id": 514, "title": "Kependudukan dan Migrasi"},
  {"sub_id": 520, "subcat_id": 514, "title": "Tenaga Kerja"},
  {"sub_id": 521, "subcat_id": 514, "title": "Pendidikan"},
  {"sub_id": 522, "subcat_id": 514, "title": "Kesehatan"},
  {"sub_id": 523, "subcat_id": 514, "title": "Konsumsi dan Pendapatan"},
  {"sub_id": 524, "subcat_id": 514, "title": "Perlindungan Sosial"},
  {"sub_id": 525, "subcat_id": 514, "title": "Pemukiman dan Perumahan"},
  {"sub_id": 526, "subcat_id": 514, "title": "Hukum dan Kriminal"},
  {"sub_id": 527, "subcat_id": 514, "title": "Budaya"},
  {"sub_id": 528, "subcat_id": 514, "title": "Aktivitas Politik dan Komunitas Lainnya"},
  {"sub_id": 529, "subcat_id": 514, "title": "Penggunaan Waktu"},
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
