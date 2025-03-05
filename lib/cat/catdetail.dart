import 'package:flutter/material.dart';
import 'package:Dalem/components/bar.dart';
// import 'package:Dalem/subcat/listDetail.dart';
import 'package:Dalem/table/table.dart' as Dalem_table;
import 'package:Dalem/components/offline_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Catdetail extends StatelessWidget {
  final String title;
  final int id;
  final String desc;
  final Color color;
  const Catdetail(
      {super.key,
      this.id = 0,
      required this.title,
      required this.desc,
      required this.color});

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
          child: Column(
            children: [
              Container(
                color: color,
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(
                      desc,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (desc.length > 100) // Adjust the length as needed
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Text(desc),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          'Baca selengkapnya',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              FutureBuilder<List<dynamic>>(
                future: fetchData(
                    'https://webapi.bps.go.id/v1/api/list/domain/3321/model/tablestatistic/subject/$id/page/1/perpage/200/key/b73ea5437eb23fb8309858b840029da2/'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(120.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/img/server.png',
                              width: 500,
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
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var item = snapshot.data![index];
                              return _buildStatisticCategory(
                                icon: Icons.bar_chart_outlined,
                                title: item['title'],
                                lastUpdate: item['last_update'] ?? '',
                                color: color,
                                onTap: () {
                                  var decodedId = utf8.decode(
                                      base64.decode(item['id'].toString()));
                                  var arrayId = decodedId.split('#');
                                  var id = arrayId[0];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Dalem_table.DataTableScreen(
                                        id: id,
                                        title: item['title'],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticCategory({
    required IconData icon,
    required String title,
    required String lastUpdate,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color, // Set the background color of the Card to blue
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(icon,
                  color: Colors.white, size: 25), // Set the icon color to white
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
                    if (lastUpdate.isNotEmpty)
                      Text(
                        'Terakhir diperbarui pada $lastUpdate', // Add last update information
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white), // Set the chevron icon color to white
            ],
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body)['data'][1];
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
        return offlineData as List<dynamic>;
      } else {
        throw Exception('Failed to load data and no offline data available');
      }
    }
  }
}
