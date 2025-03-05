import 'package:Dalem/components/bar.dart';
import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/publikasi/downloaded_publications.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Dalem/components/offline_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class DataTableScreen extends StatefulWidget {
  final String id;
  final String title;

  const DataTableScreen({super.key, required this.id, required this.title});

  @override
  DataTableScreenState createState() => DataTableScreenState();
}

class DataTableScreenState extends State<DataTableScreen> {
  late Future<Map<String, dynamic>> futureDataTable;

  @override
  void initState() {
    super.initState();
    futureDataTable = fetchDataTable();
  }

  Future<Map<String, dynamic>> fetchDataTable() async {
    final url =
        "https://webapi.bps.go.id/v1/api/list?domain=3321&model=data&lang=ind&var=${widget.id}&key=b73ea5437eb23fb8309858b840029da2";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // Save data offline
        await OfflineStorage.saveData(url, jsonResponse);
        return jsonResponse;
      } else {
        throw Exception(
            'Gagal mengambil data dari API, status: ${response.statusCode}');
      }
    } catch (e) {
      // Load data from offline storage if API call fails
      final offlineData = await OfflineStorage.loadData(url);
      if (offlineData != null) {
        return offlineData;
      } else {
        throw Exception('Terjadi kesalahan saat mengambil data');
      }
    }
  }

  String generateHtmlTable(data) {
    var html = '''
    <table border="1" style="width: 100%; border-collapse: collapse;">
      <thead>
        <tr  style="background-color: rgb(0, 43, 106); color: white; ">
          <th rowspan="3" style="border: 1px solid #ddd; padding: 12px; text-align: center; font-weight: bold;">${data['labelvervar']}</th>
    ''';

    final varData = data["var"] ?? [];
    final vervarData = data["vervar"] ?? [];
    final turvarData = data["turvar"] ?? [];
    final dataContent = data["datacontent"] ?? [] as Map<String, dynamic>;
    final tahun = data["tahun"] ?? [];
    final turTahun = data["turtahun"] ?? [];

    varData.forEach((varData) {
      html +=
          '<th colspan="${tahun.length * turvarData.length}" style="border: 1px solid #ddd; padding: 12px; text-align: center; font-weight: bold;">${varData['label']}</th>';
    });
    html +=
        '</tr><tr  style="background-color: rgb(0, 43, 106); color: white;">';

    varData.forEach((varData) {
      turvarData.forEach((element) {
        html +=
            '<th colspan="${tahun.length}" style="border: 1px solid #ddd; padding: 12px; text-align: center; font-weight: bold;">${element['label'] == 'Tidak Ada' ? 'Tahun' : element['label']}</th>';
      });
    });

    html +=
        '</tr><tr  style="background-color: rgb(0, 43, 106);color: white;">';

    varData.forEach((varData) {
      turvarData.forEach((_) {
        tahun.forEach((element) {
          html +=
              '<th style="border: 1px solid #ddd; padding: 12px; text-align: center; font-weight: bold;">${element['label']}</th>';
        });
      });
    });

    html += '</tr></thead><tbody>';

    vervarData.forEach((vervar) {
      html += '<tr>';
      html +=
          '<td style="border: 1px solid #ddd; padding: 8px 12px; text-align: center;">${vervar['label']}</td>';
      varData.forEach((varData) {
        turvarData.forEach((turvar) {
          tahun.forEach((tahun) {
            final key =
                "${vervar["val"]}${varData["val"]}${turvar["val"]}${tahun['val']}${turTahun[0]['val']}";
            html +=
                '<td style="border: 1px solid #ddd; padding: 8px 12px; text-align: center;">${dataContent[key]}</td>';
          });
        });
      });
      html += '</tr>';
    });

    html += '</tbody></table>';

    return html;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar2(
        title: 'Detail Tabel',
        
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<Map<String, dynamic>>(
          future: futureDataTable,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          futureDataTable = fetchDataTable();
                        });
                      },
                      child: Text('REFRESH MAS'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData ||
                (snapshot.data != null &&
                    snapshot.data!['data-availability'] ==
                        'list-not-available')) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(120.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/img/server.png',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'DATA BELUM TERSEDIA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              final data = snapshot.data!;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      HtmlWidget(generateHtmlTable(data)),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse(
                                'https://ppid.bps.go.id/app/konten/3321/Profil-BPS.html?_gl=1*9iomf9*_ga*ODk0Njg5NDUyLjE3MzMzNjI0NDI.*_ga_XXTTVXWHDB*MTc0MDM2MTk3My40My4xLjE3NDAzNjIyODcuMC4wLjA.'));
                          },
                          child: const Text(
                            'Hak Cipta © 2025 Badan Pusat Statistik',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.file_open,
            ),
            label: 'Publikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.download,
            ),
            label: 'Unduhan',
          ),
        ],
        currentIndex: 0, // Set the initial selected index
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey.shade700,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Homepage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchPage(autofocus: false)),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Publikasi()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DownloadedPublicationsPage()),
              );
              break;
          }
        },
        elevation: 8.0,
      ),
    );
  }
}
