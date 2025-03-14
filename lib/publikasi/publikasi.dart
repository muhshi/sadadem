import 'dart:convert';
import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/model/download.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/publikasi/detail_publikasi.dart';

class Publikasi extends StatefulWidget {
  const Publikasi({super.key});

  @override
  PublikasiState createState() => PublikasiState();
}

class PublikasiState extends State<Publikasi> {
  late ScrollController _scrollController;
  List<dynamic> publikasiList = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    fetchPublikasi();
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
      fetchPublikasi();
    }
  }

  Future<void> fetchPublikasi() async {
    setState(() {
      isLoading = true;
    });

    final url =
        'https://webapi.bps.go.id/v1/api/list/model/publication/lang/ind/domain/3321/page/$currentPage/key/b73ea5437eb23fb8309858b840029da2/';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final newPublikasi = jsonResponse['data'][1];

      setState(() {
        publikasiList.addAll(newPublikasi);
        currentPage++;
        isLoading = false;
        hasMoreData = newPublikasi.length == 10; // Assuming 10 items per page
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
        title: 'Daftar Publikasi',
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8.0),
        child: publikasiList.isEmpty && isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            controller: _scrollController,
            itemCount: publikasiList.length + (hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
          if (index == publikasiList.length) {
            return const Center(child: CircularProgressIndicator());
          }
          var item = publikasiList[index];
          return Column(
            children: [
              ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                item['cover'],
                width: 50,
                height: 50,
                fit: BoxFit.fitHeight,
              ),
            ),
            title: Text(
              item['title'],
              style: TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              item['rl_date'],
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
              builder: (context) =>
                  DetailPublikasi(publication: item),
                ),
              );
            },
              ),
              Divider(), // Add a divider between items
            ],
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
        currentIndex: 2, // Set the initial selected index to Berita
        selectedItemColor: Colors.blue.shade900,
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
