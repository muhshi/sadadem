import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
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

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(230.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.9), // Add color overlay
              image: DecorationImage(
                image: AssetImage('assets/img/stta.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Center(
                      child: Image.asset(
                      'assets/img/hometi.png',
                      height: 100,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: FutureBuilder<dynamic>(
                        future: fetchData(
                            'https://webapi.bps.go.id/v1/api/list/model/tablestatistic/lang/ind/domain/3321/keyword/strategis/key/b73ea5437eb23fb8309858b840029da2/'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CarouselSlider.builder(
                              options: CarouselOptions(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 5),
                                enlargeCenterPage: true,
                                scrollDirection: Axis.horizontal,
                              ),
                              itemCount: 3, // Number of skeleton items
                              itemBuilder: (context, index, realIndex) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors
                                      .white, // Set the card color to white
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 20,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          height: 20,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No data available'));
                          } else {
                            return CarouselSlider(
                              options: CarouselOptions(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 5),
                                enlargeCenterPage: true,
                                scrollDirection: Axis.horizontal,
                              ),
                              items: snapshot.data!['data'][1]!
                                  .map<Widget>((item) {
                                var decodedId = utf8.decode(
                                    base64.decode(item['id'].toString()));
                                var arrayId = decodedId.split('#');
                                var id = arrayId[0];

                                var titleParts =
                                    item['title'].split('Strategis] ');
                                var title = titleParts.length > 1
                                    ? titleParts[1]
                                    : item['title'];
                                return _buildStatisticCategory(
                                  title: title,
                                  color: Colors
                                      .white, // Set the card color to white
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
                              }).toList(),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(200.0);

  Widget _buildStatisticCategory({
    required String title,
    required Color color,
    required String id,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 10), // Add horizontal margin for spacing
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: color, // Set the card color to the passed color
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center all text vertically
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color.fromRGBO(100, 100, 100, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: fetchDescription(id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white));
                  } else {
                    final data = snapshot.data ?? 'No description available';
                    return Center(
                      child: Text(
                        data,
                        style: const TextStyle(
                          color: Color.fromRGBO(0, 70, 175, 1),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  }
                },
              ),
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
