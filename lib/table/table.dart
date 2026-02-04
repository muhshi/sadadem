import 'package:Dalem/components/bar.dart';
import 'package:Dalem/components/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:Dalem/components/offline_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:Dalem/components/notification_service.dart';

// class DataTableScreen extends StatefulWidget {
//   final String id;
//   final String title;

//   const DataTableScreen({super.key, required this.id, required this.title});

//   @override
//   DataTableScreenState createState() => DataTableScreenState();
// }

class DataTableScreen extends StatefulWidget {
  final String id;
  final String title;
  final String tableType; // tambahkan ini

  const DataTableScreen({
    super.key,
    required this.id,
    required this.title,
    required this.tableType,
  });

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
    String url;
    // Ambil hanya bagian sebelum '#' untuk API
    final idParts = widget.id.split('#');
    final idOnly = idParts[0];

    if (widget.tableType == '1') {
      // Statictable
      url =
          "https://webapi.bps.go.id/v1/api/view/domain/3321/model/statictable/id/$idOnly/lang/ind/key/b73ea5437eb23fb8309858b840029da2/";
    } else if (widget.tableType == '2') {
      // Dynamic
      url =
          "https://webapi.bps.go.id/v1/api/list?domain=3321&model=data&lang=ind&var=$idOnly&th=024&key=b73ea5437eb23fb8309858b840029da2";
    } else {
      throw Exception('Tipe tabel tidak dikenali');
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final Map<String, dynamic> castedResponse =
            (jsonResponse as Map).cast<String, dynamic>();
        await OfflineStorage.saveData(url, castedResponse);
        return castedResponse;
      } else {
        throw Exception(
            'Gagal mengambil data dari API, status: ${response.statusCode}');
      }
    } catch (e) {
      final offlineData = await OfflineStorage.loadData(url);
      if (offlineData != null) {
        return offlineData.cast<String, dynamic>();
      } else {
        throw Exception('Terjadi kesalahan saat mengambil data');
      }
    }
  }
  // Future<Map<String, dynamic>> fetchDataTable() async {
  //   final url =
  //       "https://webapi.bps.go.id/v1/api/list?domain=3321&model=data&lang=ind&var=${widget.id}&th=025&key=b73ea5437eb23fb8309858b840029da2";
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       debugPrint(jsonResponse.toString());
  //       // Pastikan data dikonversi ke Map<String, dynamic>
  //       final Map<String, dynamic> castedResponse =
  //           (jsonResponse as Map).cast<String, dynamic>();
  //       // Save data offline
  //       await OfflineStorage.saveData(url, castedResponse);
  //       return castedResponse;
  //     } else {
  //       throw Exception(
  //           'Gagal mengambil data dari API, status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Load data from offline storage if API call fails
  //     final offlineData = await OfflineStorage.loadData(url);
  //     if (offlineData != null) {
  //       return offlineData.cast<String, dynamic>();
  //     } else {
  //       throw Exception('Terjadi kesalahan saat mengambil data');
  //     }
  //   }
  // }

  String generateHtmlTable(data) {
    var html = '''
    <table border="1" style="width: 100%; border-collapse: collapse;">
      <thead>
        <tr style="background-color: rgb(0, 43, 106); color: white;">
          <th rowspan="3" style="border: 1px solid #ddd; padding: 12px; text-align: center; font-weight: bold;">${data['labelvervar']}</th>
    ''';
    final varData =
        (data["var"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final vervarData =
        (data["vervar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final turvarData =
        (data["turvar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final dataContent =
        (data["datacontent"] as Map?)?.cast<String, dynamic>() ?? {};
    final tahun =
        (data["tahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final turTahun =
        (data["turtahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            [];

    for (var varData in varData) {
      html +=
          '<th colspan="${tahun.length * turvarData.length}" style="border: 1px solid #ddd; padding: 12px; text-align: center; font-weight: bold;">${varData['label']}</th>';
    }
    html +=
        '</tr><tr style="background-color: rgb(0, 43, 106); color: white;">';

    for (var varData in varData) {
      for (var element in turvarData) {
        html +=
            '<th colspan="${tahun.length}" style="border: 1px solid #ddd; padding: 12px; text-align: center; font-weight: bold;">${element['label'] == 'Tidak Ada' ? 'Tahun' : element['label']}</th>';
      }
    }

    html +=
        '</tr><tr style="background-color: rgb(0, 43, 106); color: white;">';

    for (var varData in varData) {
      for (var _ in turvarData) {
        for (var element in tahun) {
          html +=
              '<th style="border: 1px solid #ddd; padding: 12px; text-align: center; font-weight: bold;">${element['label']}</th>';
        }
      }
    }

    html += '</tr></thead><tbody>';

    for (var vervar in vervarData) {
      html += '<tr>';
      html +=
          '<td style="border: 1px solid #ddd; padding: 8px 12px; text-align: center;">${vervar['label']}</td>';
      for (var varData in varData) {
        for (var turvar in turvarData) {
          for (var tahun in tahun) {
            final key =
                "${vervar["val"]}${varData["val"]}${turvar["val"]}${tahun['val']}${turTahun[0]['val']}";
            String value = dataContent[key]?.toString() ?? '-';
            if (value != '-') {
              value = value.replaceAll('.', ',');
              value = value.replaceAllMapped(
                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
            }
            html +=
                '<td style="border: 1px solid #ddd; padding: 8px 12px; text-align: center;">$value</td>';
          }
        }
      }
      html += '</tr>';
    }

    html += '</tbody></table>';

    return html;
  }

  String generateCsv(data) {
    final varData =
        (data["var"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final vervarData =
        (data["vervar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final turvarData =
        (data["turvar"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final dataContent =
        (data["datacontent"] as Map?)?.cast<String, dynamic>() ?? {};
    final tahun =
        (data["tahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final turTahun =
        (data["turtahun"] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            [];

    List<List<String>> csvData = [];

    // Header
    List<String> header1 = [''];
    for (var varData in varData) {
      header1.addAll(
          List.filled(tahun.length * turvarData.length, varData['label']));
    }
    csvData.add(header1);

    List<String> header2 = [data['labelvervar']];
    for (var varData in varData) {
      for (var element in turvarData) {
        header2.addAll(List.filled(tahun.length,
            element['label'] == 'Tidak Ada' ? 'Tahun' : element['label']));
      }
    }
    csvData.add(header2);

    List<String> header3 = [''];
    for (var varData in varData) {
      for (var _ in turvarData) {
        for (var tahun in tahun) {
          header3.add(tahun['label']);
        }
      }
    }
    csvData.add(header3);

    // Rows
    for (var vervar in vervarData) {
      List<String> row = [vervar['label']];
      for (var varData in varData) {
        for (var turvar in turvarData) {
          for (var tahun in tahun) {
            final key =
                "${vervar["val"]}${varData["val"]}${turvar["val"]}${tahun['val']}${turTahun[0]['val']}";
            row.add(dataContent[key]?.toString() ?? '-');
          }
        }
      }
      csvData.add(row);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  Future<void> downloadCsv(String csv) async {
  final directory = Directory('/storage/emulated/0/Download/Dalem');
  // Gunakan seluruh id, ganti # dengan _ agar nama file valid dan unik
  final safeId = widget.id.replaceAll('#', '_');
  final path = '${directory.path}/${widget.title}_$safeId.xls';
  final file = File(path);
  await file.writeAsString(csv);

  if (mounted) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Unduhan Berhasil'),
          content: Text('File disimpan di: $path'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

  // Future<void> downloadCsv(String csv) async {
  //   final directory = Directory('/storage/emulated/0/Download/Dalem');
  //   final path = '${directory.path}/${widget.title}.xls';
  //   final file = File(path);
  //   await file.writeAsString(csv);

  //   if (mounted) {
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text('Unduhan Berhasil'),
  //           content: Text('File disimpan di: $path'),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            } else if (snapshot.hasError ||
                snapshot.data is! Map<String, dynamic>) {
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
                        child: data["datacontent"] != null &&
                                data["datacontent"].isNotEmpty
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                ),
                                onPressed: () async {
                                  final csv = generateCsv(data);
                                  await downloadCsv(csv);
                                },
                                child: Text(
                                  'Download',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : SizedBox
                                .shrink(), // Tidak menampilkan apapun jika data kosong
                      ),
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
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom navigation tap if needed
        },
      ),
    );
  }
}
