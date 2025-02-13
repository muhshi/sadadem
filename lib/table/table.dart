import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class DataTableScreen extends StatefulWidget {
  final String id;
  final String title;

  const DataTableScreen({super.key, required this.id, required this.title});

  @override
  _DataTableScreenState createState() => _DataTableScreenState();
}

class _DataTableScreenState extends State<DataTableScreen> {
  late Future<Map<String, dynamic>> futureDataTable;

  @override
  void initState() {
    super.initState();
    futureDataTable = fetchDataTable();
  }

  Future<Map<String, dynamic>> fetchDataTable() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://webapi.bps.go.id/v1/api/list?domain=3321&model=data&lang=ind&var=${widget.id}&key=b73ea5437eb23fb8309858b840029da2",
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception(
        'Gagal mengambil data dari API, status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data');
    }
  }

  String generateHtmlTable(data) {
    var html = '''
    <table border="1" style="width: 100%; border-collapse: collapse;">
      <thead>
        <tr  style="background-color: rgb(0, 43, 106); color: white; ">
          <th rowspan="3" style="border: 1px solid #ddd; padding: 12px; text-align: center; font-weight: bold;">${data['labelvervar']}</th>
    ''';

    final varData = data["var"] ??[];
    final vervarData = data["vervar"] ??[];
    final turvarData = data["turvar"]  ?? [];
    final dataContent = data["datacontent"] ?? [] as Map<String, dynamic>;
    final tahun = data["tahun"] ?? [];
    final turTahun = data["turtahun"] ?? [];

    varData.forEach((varData) {
      html += '<th colspan="${tahun.length * turvarData.length}" style="border: 1px solid #ddd; padding: 12px; text-align: center; font-weight: bold;">${varData['label']}</th>';
    });
    html += '</tr><tr  style="background-color: rgb(0, 43, 106); color: white;">';

    varData.forEach((varData) {
      turvarData.forEach((element) {
        html += '<th colspan="${tahun.length}" style="border: 1px solid #ddd; padding: 12px; text-align: center; font-weight: bold;">${element['label']=='Tidak Ada'?'Tahun':element['label']}</th>';
      });
    });

    html += '</tr><tr  style="background-color: rgb(0, 43, 106);color: white;">';

    varData.forEach((varData) {
      turvarData.forEach((_) {
        tahun.forEach((element) {
          html += '<th style="border: 1px solid #ddd; padding: 12px; text-align: center; font-weight: bold;">${element['label']}</th>';
        });
      });
    });

    html += '</tr></thead><tbody>';

    vervarData.forEach((vervar) {
      html += '<tr>';
      html += '<td style="border: 1px solid #ddd; padding: 8px 12px; text-align: center;">${vervar['label']}</td>';
      varData.forEach((varData) {
        turvarData.forEach((turvar) {
          tahun.forEach((tahun) {
            final key = "${vervar["val"]}${varData["val"]}${turvar["val"]}${tahun['val']}${turTahun[0]['val']}";
            html += '<td style="border: 1px solid #ddd; padding: 8px 12px; text-align: center;">${dataContent[key]}</td>';
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
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 43, 106, 1),
        leading: IconButton(
          icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          onPressed: () {
        Navigator.pop(context);
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 25, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: 
      
      FutureBuilder<Map<String, dynamic>>(
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
          } else if (!snapshot.hasData || (snapshot.data != null && snapshot.data!['data-availability'] == 'list-not-available')) {
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
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
          } else {
            final data = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: HtmlWidget(generateHtmlTable(data)),
            );
          }
        },
      ),

    );
  }
}
