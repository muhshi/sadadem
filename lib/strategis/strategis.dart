import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/table/table.dart';
import 'package:Dalem/components/offline_storage.dart';

Future<Map<String, dynamic>> fetchData(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Save data offline
      await OfflineStorage.saveData(url, jsonResponse);
      return jsonResponse;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    // Load data from offline storage if API call fails
    final offlineData = await OfflineStorage.loadData(url);
    if (offlineData != null) {
      return offlineData;
    } else {
      throw Exception('Failed to load data and no offline data available');
    }
  }
}

class Strategis extends StatefulWidget {
  final String title;
  final Color color;

  const Strategis({super.key, required this.title, required this.color});

  @override
  _StrategisState createState() => _StrategisState();
}

class _StrategisState extends State<Strategis> {
  List<Map<String, dynamic>> searchHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar2(
        title: widget.title,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<dynamic>(
                future: fetchData(
                  'https://webapi.bps.go.id/v1/api/list/model/tablestatistic/lang/ind/domain/3321/keyword/strategis/key/b73ea5437eb23fb8309858b840029da2/',
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  } else {
                    searchHistory.add(snapshot.data!);
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      itemCount: snapshot.data!['data'][1]!.length,
                      itemBuilder: (context, index) {
                        var item = snapshot.data!['data'][1]![index];
                        var decodedId =
                            utf8.decode(base64.decode(item['id'].toString()));
                        var arrayId = decodedId.split('#');
                        var id = arrayId[0];

                        var titleParts = item['title'].split('Strategis] ');
                        var title = titleParts.length > 1
                            ? titleParts[1]
                            : item['title'];
                        return _buildStatisticCategory(
                          title: title,
                          color: widget.color,
                          id: id,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DataTableScreen(
                                id: id,
                                title: title,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticCategory({
    required id,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
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
                    const SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: fetchDescription(id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            width: double.infinity,
                            height: 20.0,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white));
                        } else {
                          final data =
                              snapshot.data ?? 'No description available';
                          return Text(
                            data,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          );
                        }
                      },
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

  Future<String> fetchDescription(String id) async {
    try {
      final response = await fetchData(
          'https://webapi.bps.go.id/v1/api/list?domain=3321&model=data&lang=ind&var=$id&key=b73ea5437eb23fb8309858b840029da2');
      final data = response ?? {};
      final vervarData = data["vervar"] ?? [];
      final varData = data["var"] ?? [];
      final turvarData = data["turvar"] ?? [];
      final dataContent = data["datacontent"] ?? {} as Map<String, dynamic>;
      final tahun = data["tahun"] ?? [];
      final turTahun = data["turtahun"] ?? [];

      var unit = varData[varData.length - 1]["unit"] ?? '';
      var key =
          '${vervarData[vervarData.length - 1]["val"]}${varData[varData.length - 1]["val"]}${turvarData[turvarData.length - 1]["val"]}${tahun[tahun.length - 1]["val"]}${turTahun[turTahun.length - 1]["val"]}';
      var resValue = "${dataContent[key]} $unit";
      var resTahun = tahun[tahun.length - 1]["label"];
      return '$resValue ($resTahun)';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
