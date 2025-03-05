import 'dart:convert';
import 'package:Dalem/berita/detail_berita.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

class Homeberita extends StatefulWidget {
  final String title;
  final Function() onSeeAll;

  const Homeberita({super.key, required this.title, required this.onSeeAll});

  @override
  HomeberitaState createState() => HomeberitaState();
}

class HomeberitaState extends State<Homeberita> {
  late Future<List<dynamic>> futureBerita;

  @override
  void initState() {
    super.initState();
    futureBerita = fetchBerita();
  }

  Future<List<dynamic>> fetchBerita() async {
    final url =
        'https://webapi.bps.go.id/v1/api/list/model/news/lang/ind/domain/3321/key/b73ea5437eb23fb8309858b840029da2/';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return [jsonResponse['data'][1][0]]; // Limit data to only one item
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futureBerita,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(128),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: widget.onSeeAll,
                  icon: Icon(Icons.arrow_forward, color: Colors.blue.shade900),
                  label: Text(
                    'Lihat Semua',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var item = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                item['picture'],
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              item['rl_date'] ?? 'No Date',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 10),
                            HtmlWidget(
                              HtmlUnescape().convert(item['title'] ?? 'No Title'),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailBerita(newsId: item['news_id'].toString()),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
