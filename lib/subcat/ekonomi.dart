import 'package:Dalem/components/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:Dalem/cat/catdetail.dart';
import 'package:Dalem/components/bar.dart';

class ListDetail515 extends StatelessWidget {
  final int id;
  final String title;
  final Color color;

  const ListDetail515(
      {super.key, required this.id, required this.title, required this.color});

  final List<Map<String, dynamic>> staticData = const [
  {"sub_id": 530, "subcat_id": 515, "title": "Statistik Makroekonomi"},
  {"sub_id": 531, "subcat_id": 515, "title": "Neraca Ekonomi"},
  {"sub_id": 532, "subcat_id": 515, "title": "Statistik Bisnis"},
  {"sub_id": 533, "subcat_id": 515, "title": "Statistik sektoral"},
  {"sub_id": 534, "subcat_id": 515, "title": "Keuangan Pemerintah, Fiskal dan Statistik Sektor Publik"},
  {"sub_id": 535, "subcat_id": 515, "title": "Perdagangan Internasional dan Neraca Pembayaran"},
  {"sub_id": 536, "subcat_id": 515, "title": "Harga-Harga"},
  {"sub_id": 537, "subcat_id": 515, "title": "Biaya Tenaga Kerja"},
  {"sub_id": 538, "subcat_id": 515, "title": "Ilmu Pengetahuan, Teknologi, dan Inovasi"},
  {"sub_id": 557, "subcat_id": 515, "title": "Pertanian, Kehutanan, Perikanan"},
  {"sub_id": 558, "subcat_id": 515, "title": "Energi"},
  {"sub_id": 559, "subcat_id": 515, "title": "Pertambangan, Manufaktur, Konstruksi"},
  {"sub_id": 560, "subcat_id": 515, "title": "Transportasi"},
  {"sub_id": 561, "subcat_id": 515, "title": "Pariwisata"},
  {"sub_id": 562, "subcat_id": 515, "title": "Perbankan, Asuransi dan Finansial"},

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
