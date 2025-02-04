import 'package:flutter/material.dart';
import 'demografi.dart';
// import 'ekonomi.dart';
// import 'lingkungan.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 200, // Tinggi AppBar disesuaikan
        flexibleSpace: Container(
          margin: const EdgeInsets.only(bottom: 1), // Margin bawah
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 100, 182),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: 20,  // Posisi dari tepi kanan
                top: 70,    // Posisi dari atas
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: Image(
                      image: AssetImage('assets/img/stta.jpg'),
                      width: 190,
                      height: 115,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 20,
                top: 75, // Posisi disesuaikan
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Data Statistik apa\nyang sedang dicari?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Tenang, Kami bantu carikan\nYa..",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Warna background transparan
        elevation: 0, // Hilangkan shadow
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _buildStatisticCategory(
                icon: Icons.people_alt,
                title: "Statistik Demografi dan Sosial",
                color: Colors.blue,
                onTap: () {
                  // Navigasi ke halaman Demografi
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Demografi()),
                  );
                },
              ),
              _buildStatisticCategory(
                icon: Icons.attach_money,
                title: "Statistik Ekonomi",
                color: Colors.green,
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const Ekonomi()),
                  // );
                },
              ),
              _buildStatisticCategory(
                icon: Icons.public,
                title: "Statistik Lingkungan Hidup dan Multi-domain",
                color: Colors.orange,
                onTap: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => const Lingkungan()),
                //   );
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "10+ DATA DISIMPAN",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticCategory({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap, // Tambahkan parameter onTap
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap, // Gunakan parameter onTap
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}