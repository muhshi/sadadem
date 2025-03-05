import 'dart:convert';
import 'package:Dalem/berita/detail_berita.dart';
import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/publikasi/downloaded_publications.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:Dalem/components/bar.dart';

class Berita extends StatefulWidget {
  const Berita({super.key});

  @override
  BeritaState createState() => BeritaState();
}

class BeritaState extends State<Berita> {
  late ScrollController _scrollController;
  List<dynamic> beritaList = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    fetchBerita();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMoreData) {
      fetchBerita();
    }
  }

  Future<void> fetchBerita() async {
    setState(() {
      isLoading = true;
    });

    final url =
        'https://webapi.bps.go.id/v1/api/list/model/news/lang/ind/domain/3321/page/$currentPage/perpage/10/key/b73ea5437eb23fb8309858b840029da2/';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final newBerita = jsonResponse['data'][1];

      setState(() {
        beritaList.addAll(newBerita);
        currentPage++;
        isLoading = false;
        hasMoreData = newBerita.length == 10; // Assuming 10 items per page
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar2(
        title: 'Berita Kegiatan BPS',
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8.0),
        child: beritaList.isEmpty && isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78,
                ),
                itemCount: beritaList.length + (hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == beritaList.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var item = beritaList[index];
                  return Card(
                    color: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.grey,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailBerita(
                                newsId: item['news_id'].toString()),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            item['picture'] != null &&
                                    item['picture'].isNotEmpty
                                ? Image.network(
                                    item['picture'],
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Icon(Icons.error),
                                  )
                                : Container(),
                            const SizedBox(height: 5),
                            Text(
                              item['title'] ?? 'No Title',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_open),
            label: 'Publiksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Unduhan',
          ),
        ],
        currentIndex: 0, // Set the initial selected index to Berita
        selectedItemColor: Colors.grey.shade700,
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
      ),
    );
  }
}
