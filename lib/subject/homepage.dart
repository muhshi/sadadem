import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Dalem/subcat/listsubcat.dart';
import 'dart:convert';

Future<List<dynamic>> fetchData(url) async {
  final response = await http.get(Uri.parse(url));
  print(url);
  if (response.statusCode == 200) {
    return json.decode(response.body)['data'][1];
  } else {
    throw Exception('Failed to load data');
  }
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 230, // Tinggi AppBar disesuaikan
        flexibleSpace: Container(
          margin: const EdgeInsets.only(bottom: 20), // Margin bawah
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 43, 106, 1),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: 20,
                left: 230,
                top: 80,
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
              Positioned(
                left: 20,
                top: 85, // Posisi disesuaikan
                right: 230, // Tambahkan batas kanan untuk auto enter
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Data Statistik apa yang sedang dicari?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Tenang, Kami bantu carikan Ya..",
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
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        elevation: 0, // Hilangkan shadow
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchData('https://webapi.bps.go.id/v1/api/list/domain/3321/model/subcatcsa/key/b73ea5437eb23fb8309858b840029da2/'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0), // Add horizontal padding
                      child: Row(
                      children: [
                        Expanded(
                        child: _buildStatisticCategory(
                          title: snapshot.data![0]['title'],
                          color: Colors.blue.shade900,
                          imageUrl: 'assets/img/demografi.png',
                          width: 150,
                          height: 150,
                          onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ListDetail(id: snapshot.data![0]['subcat_id'], title: snapshot.data![0]['title'])),
                          ),
                          },
                        ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                        child: _buildStatisticCategory(
                          title: snapshot.data![1]['title'],
                          color: Colors.green.shade700,
                          imageUrl: 'assets/img/ekonomi.png',
                          width: 150,
                          height: 150,
                          additionalText: 'Additional text here',
                          onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ListDetail(id: snapshot.data![1]['subcat_id'], title: snapshot.data![1]['title'])),
                          ),
                          },
                        ),
                        ),
                      ],
                      ),
                    ),
                    const SizedBox(height: 10), // Add spacing between rows
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: _buildStatisticCategory(
                          title: snapshot.data![2]['title'],
                          color: Colors.orange.shade700,
                          imageUrl: 'assets/img/lingkungan.png',
                          width: 100,
                          height: 100,
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ListDetail(id: snapshot.data![2]['subcat_id'], title: snapshot.data![2]['title']))),
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatisticCategory({
    required String title,
    required Color color,
    required String imageUrl,
    required double width,
    required double height,
    String? additionalText,
    VoidCallback? onTap,
  }) {
    return Card(
      color: color, // Set the color of the card
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: InkWell(
        onTap: onTap, // Gunakan parameter onTap
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            SizedBox(height: 15), // Tambahkan SizedBox di sini
            SizedBox(
              width: 150,
              height: 150, // Ubah ukuran sesuai kebutuhan
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.asset(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                _formatTitle(title),
                textAlign: TextAlign.center, // Posisikan teks di tengah
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTitle(String title) {
    List<String> words = title.split(' ');
    if (words.length <= 2) {
      return '$title\n';
    }
    for (int i = 2; i < words.length; i += 4) {
      words.insert(i, '\n');
    }
    return words.join(' ');
  }
}
