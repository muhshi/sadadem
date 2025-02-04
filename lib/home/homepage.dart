import 'package:flutter/material.dart';
import '../demografi/demografi.dart';
// import 'ekonomi.dart';
// import 'lingkungan.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 220, // Tinggi AppBar disesuaikan
        flexibleSpace: Container(
          margin: const EdgeInsets.only(bottom: 1), // Margin bawah
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 90, 163),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: 20,  // Posisi dari tepi kanan
                top: 80,    // Posisi dari atas
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
                top: 85, // Posisi disesuaikan agar berada di bawah gambar
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
              const SizedBox(height: 20),
              // Baris pertama dengan 2 kotak
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatisticCategory(
                    title: "Statistik Demografi\n dan Sosial",
                    color: Colors.blue,
                    imagePath: 'assets/img/demografi.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Demografi()),
                      );
                    },
                  ),
                  _buildStatisticCategory(
                    title: "Statistik Ekonomi",
                    color: Colors.green,
                    imagePath: 'assets/img/ekonomi.png',
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const Ekonomi()),
                      // );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Kotak bawah
              Center(
                child: _buildStatisticCategory(
                  title: "Statistik Lingkungan\nHidup dan Multi-domain",
                  color: Colors.orange,
                  imagePath: 'assets/img/lingkungan.png',
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const Lingkungan()),
                    // );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticCategory({
    required String title,
    required Color color,
    required String imagePath,
    VoidCallback? onTap, // Tambahkan parameter onTap
  }) {
    return SizedBox(
      width: 150,
      height: 230, // Set height to make all boxes the same size
      child: Card(
        color: color, // Set the card color to match the category color
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: InkWell(
          onTap: onTap, // Gunakan parameter onTap
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
              children: [
                Image.asset(
                  imagePath,
                  width: 150,
                  height: 80,
                ),
                const SizedBox(height: 10), // Space before the text
                Spacer(), // Add a spacer to push the text to the bottom
                Text(
                  title,
                  textAlign: TextAlign.center, // Center the text
                  style: const TextStyle(
                    fontSize: 12, // Adjust font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Adjust text color
                  ),
                ),
                const SizedBox(height: 5), // Space between texts
                Text(
                  "10+ DATA DISIMPAN",
                  textAlign: TextAlign.center, // Center the text
                  style: const TextStyle(
                    fontSize: 9, // Adjust font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Adjust text color
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