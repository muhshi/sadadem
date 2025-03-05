import 'dart:io';

import 'package:Dalem/components/bar.dart';
import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/publikasi/downloaded_publications.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailBerita extends StatefulWidget {
  final String newsId;

  const DetailBerita({super.key, required this.newsId});

  @override
  _DetailBeritaState createState() => _DetailBeritaState();
}

class _DetailBeritaState extends State<DetailBerita> {
  late Future<Map<String, dynamic>> futureNews;

  @override
  void initState() {
    super.initState();
    futureNews = fetchDetailBerita(widget.newsId);
  }

  Future<Map<String, dynamic>> fetchDetailBerita(String newsId) async {
    final detailUrl =
        'https://webapi.bps.go.id/v1/api/view/domain/3321/model/news/lang/ind/id/$newsId/key/b73ea5437eb23fb8309858b840029da2/';
    final detailResponse = await http.get(Uri.parse(detailUrl));
    if (detailResponse.statusCode == 200) {
      return json.decode(detailResponse.body)['data'];
    } else {
      throw Exception('Failed to load detail data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar2(
        title: 'Detail Berita',
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<Map<String, dynamic>>(
          future: futureNews,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            } else {
              var news = snapshot.data!;
              var relatedNews = news['related'] as List<dynamic>? ?? [];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news['title'] ?? 'No Title',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      news['rl_date'] ?? 'No Date',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    news['picture'] != null && news['picture'].isNotEmpty
                        ? Image.network(
                            news['picture'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 200,
                              color: Colors.grey.shade200,
                              child: Center(child: Icon(Icons.error)),
                            ),
                          )
                        : Container(),
                    SizedBox(height: 16),
                    news['news'] != null
                        ? HtmlWidget(HtmlUnescape()
                            .convert(news['news'] ?? 'No Content'))
                        : Text('No Content', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 32),
                    Text(
                      'Berita Terkait',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: relatedNews.length,
                      itemBuilder: (context, index) {
                        var related = relatedNews[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: related['picture'] != null &&
                                  related['picture'].isNotEmpty
                              ? Image.network(
                                  related['picture'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey.shade200,
                                    child: Center(child: Icon(Icons.error)),
                                  ),
                                )
                              : SizedBox(width: 50, height: 50),
                          title: Text(related['title'] ?? 'No Title'),
                          subtitle: Text(related['rl_date'] ?? 'No Date'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailBerita(
                                    newsId: related['news_id'].toString()),
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
        ),
      ),
      floatingActionButton: FutureBuilder<Map<String, dynamic>>(
        future: futureNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return FloatingActionButton(
              onPressed: () async {
                var news = snapshot.data!;

                final title = news['title'] ?? 'No Title';
                final date = news['rl_date'] ?? 'No Date';
                final document = HtmlUnescape().convert(news['news'] ?? '');
                final isi = document.replaceAll(RegExp(r'<[^>]*>'), '\n');
                var urlDate = date.replaceAll('-', '/');
                final url = 'https://demakkab.bps.go.id/id/news/$urlDate/${news['news_id']}'; 
                final picture = news['picture'] ?? '';

                if (picture.isNotEmpty) {
                  final uri = Uri.parse(picture);
                  final response = await http.get(uri);
                  final bytes = response.bodyBytes;
                  final tempDir = await getTemporaryDirectory();
                  final file = await File('${tempDir.path}/image.png').create();
                  await file.writeAsBytes(bytes);
                  var xfile = XFile(file.path);
                  await Share.shareXFiles(
                    [xfile],
                    text: '$title\n$isi\n$url',
                    subject: 'Check out this news!',
                  );
                } else {
                  await Share.share(
                    '$title\n\n$date\n\n$url',
                    subject: 'Check out this news!',
                  );
                }
              },
              backgroundColor: Colors.blue.shade600,
              child: Icon(Icons.share, color: Colors.white),
            );
          } else {
            return Container(); // Return an empty container when the future is not done
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
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
            label: 'Publikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Unduhan',
          ),
        ],
        currentIndex: 2, // Set the initial selected index to Berita
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
