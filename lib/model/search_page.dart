import 'package:Dalem/berita/detail_berita.dart';
import 'package:Dalem/model/download.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/publikasi/detail_publikasi.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/table/table.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  final bool autofocus;
  const SearchPage({super.key, required this.autofocus});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    final urls = [
      {
        'url':
            'https://webapi.bps.go.id/v1/api/list/model/tablestatistic/lang/ind/domain/3321/keyword/$query/key/b73ea5437eb23fb8309858b840029da2/',
        'type': 'table'
      },
      {
        'url':
            'https://webapi.bps.go.id/v1/api/list/model/publication/lang/ind/domain/3321/keyword/$query/key/b73ea5437eb23fb8309858b840029da2/',
        'type': 'publication'
      },
      {
        'url':
            'https://webapi.bps.go.id/v1/api/list/model/news/lang/ind/domain/3321/keyword/$query/key/b73ea5437eb23fb8309858b840029da2/',
        'type': 'news'
      },
      {
      'url':
          'https://webapi.bps.go.id/v1/api/list/model/infographic/lang/ind/domain/3321/keyword/$query/key/b73ea5437eb23fb8309858b840029da2/',
      'type': 'infographic'
      },
    ];

    List<Map<String, dynamic>> results = [];

    try {
      await Future.wait(urls.map((urlData) async {
        final response = await http.get(Uri.parse(urlData['url'].toString()));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          for (var item in data['data'][1]) {
            item['type'] = urlData['type'];
            results.add(item);
          }
        }
      }));

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });

      _saveSearchQuery(query);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching search results: $e');
    }
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_searchHistory.contains(query)) {
      _searchHistory.add(query);
      await prefs.setStringList('searchHistory', _searchHistory);
    }
  }

  Future<void> _deleteSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.remove(query);
    });
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar2(
          title: 'Cari Data',
        ),
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                autofocus: widget.autofocus,
                onChanged: (value) {
                  _onSearchChanged();
                },
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Cari Data',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _performSearch(_searchController.text);
                    },
                  ),
                ),
                onSubmitted: (value) {
                  _performSearch(value);
                },
              ),
              SizedBox(height: 16.0),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: _searchResults.isNotEmpty
                          ? ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                var item = _searchResults[index];
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        item['title'] ?? 'No Title',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      subtitle: Container(
                                        padding: EdgeInsets.all(4.0),
                                        child: Text(
                                          item['type'],
                                          style: TextStyle(
                                              color: Colors.blue.shade900,
                                              fontSize: 16),
                                        ),
                                      ),
                                      trailing: Icon(
                                          Icons.keyboard_arrow_right_sharp),
                                      onTap: () {
                                        try {
                                          if (item['type'] == 'table') {
                                            var decodedId = utf8.decode(base64
                                                .decode(item['id'].toString()));
                                            var arrayId = decodedId.split('#');
                                            var id = arrayId[0];
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DataTableScreen(
                                                        id: id,
                                                        title: item['title']),
                                              ),
                                            );
                                            } else if (item['type'] ==
                                                'publication') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailPublikasi(
                                                          publication: item),
                                                ),
                                              );
                                            } else if (item['type'] == 'news') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailBerita(newsId: item['news_id'].toString()),
                                                ),
                                              );
                                            } else if (item['type'] == 'infographic'){
                                              _showFullScreenImage(context, item['img']);
                                            }
                                        
                                          }
                                        catch (e) {
                                          debugPrint('Error decoding ID: $e');
                                        }
                                      },
                                    ),
                                    Divider(),
                                  ],
                                );
                              },
                            )
                          : _searchHistory.isNotEmpty
                              ? ListView.builder(
                                  itemCount: _searchHistory.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: Icon(Icons.history),
                                      onTap: () {
                                        _searchController.text =
                                            _searchHistory[index];
                                        _performSearch(_searchHistory[index]);
                                      },
                                      title: Text(_searchHistory[index]),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.clear),
                                            onPressed: () {
                                              _deleteSearchQuery(
                                                  _searchHistory[index]);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text('Belum ada riwayat pencarian')),
                    ),
            ],
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
              label: 'Publikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.download),
              label: 'Unduhan',
            ),
          ],
          currentIndex: 1, // Set the initial selected index to SearchPage
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
      ),
    );
  }
  void _showFullScreenImage(
      BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child:Image.network(
                          imagePath,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
