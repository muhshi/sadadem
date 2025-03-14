import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:Dalem/components/bar.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class Infographic extends StatefulWidget {
  const Infographic({super.key});

  @override
  InfographicState createState() => InfographicState();
}

class InfographicState extends State<Infographic> {
  late ScrollController _scrollController;
  List<dynamic> infographicList = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMoreData = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _permissionGranted = false;
  late List<dynamic> _downloadedFiles = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    fetchInfographic();
    _requestPermissionAndLoadFiles();
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
      fetchInfographic();
    }
  }

  Future<void> _requestPermissionAndLoadFiles() async {
    if (await _requestPermission(Permission.storage)) {
      setState(() {
        _permissionGranted = true;
      });
      _downloadedFiles = await _loadDownloadedFiles();
    } else {
      setState(() {
        _permissionGranted = false;
      });
    }
  }

  Future<List> _loadDownloadedFiles() async {
    final directory = Directory('/storage/emulated/0/Download/Dalem');
    if (!await directory.exists()) {
      return [];
    }
    final files = directory
        .listSync()
        .where((item) =>
            item.path.endsWith('.jpg') ||
            item.path.endsWith('.jpg') ||
            item.path.endsWith('.png'))
        .map((item) => {
              'title': item.path.split('/').last.replaceFirst('.jpg', ''),
              'image': item.path,
            })
        .toList();
    return files;
  }

  Future<void> fetchInfographic() async {
    setState(() {
      isLoading = true;
    });

    final url =
        'https://webapi.bps.go.id/v1/api/list/model/infographic/lang/ind/domain/3321/page/$currentPage/perpage/10/key/b73ea5437eb23fb8309858b840029da2/';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final newInfographic = jsonResponse['data'][1];

      setState(() {
        infographicList.addAll(newInfographic);
        currentPage++;
        isLoading = false;
        hasMoreData = newInfographic.length == 10; // Assuming 10 items per page
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
        title: 'Daftar Infografis',
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8.0),
        child: infographicList.isEmpty && isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.56,
                ),
                itemCount: infographicList.length + (hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == infographicList.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var item = infographicList[index];
                  bool isDownloaded = _downloadedFiles
                      .any((file) => file['title'] == item['title']);
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      border: Border.all(color: Colors.white),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          item['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8.0),
                        AspectRatio(
                          aspectRatio: 1 /
                              1.414, // Aspect ratio of A4 is approximately 1:1.414
                          child: GestureDetector(
                            onTap: () {
                              var info = item;
                              _showFullScreenImage(
                                  context, info['img']!, info['title'], false);
                            },
                            child: Image.network(
                              item['img'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.0),
                        if (isDownloaded)
                          ElevatedButton.icon(
                            // icon: Icon(Icons.open_in_new, color: Colors.white),
                            label: Text('Buka',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .blue, // Set the background color to blue
                            ),
                            onPressed: () {
                              var info = _downloadedFiles.firstWhere(
                                  (file) => file['title'] == item['title']);
                              _showFullScreenImage(
                                  context, info['image']!, info['title'], true);
                            },
                          )
                        else
                          ElevatedButton.icon(
                            // icon: Icon(Icons.download, color: Colors.white),
                            label: Text('Unduh',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .blue, // Set the background color to blue
                            ),
                            onPressed: () {
                              _downloadImage(
                                  context, item['img'], item['title']);
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _downloadImage(
      BuildContext context, String url, String title) async {
    if (await _requestPermission(Permission.storage)) {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      try {
        final directory = Directory('/storage/emulated/0/Download/Dalem');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        final filePath = '${directory.path}/$title.jpg';
        final file = File(filePath);

        await Dio().download(
          url,
          file.path,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                _downloadProgress = (received / total);
              });
            }
          },
        );

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Download Successful'),
              content: Text('File saved at: $filePath'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        setState(() {
          _downloadedFiles.add({
            'title': title,
            'image': file.path,
          });
        });
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading image: $e')),
        );
      } finally {
        setState(() {
          _isDownloading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied')),
      );
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      final result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  void _showFullScreenImage(
      BuildContext context, String imagePath, String title, bool isFile) {
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
                  child: isFile
                      ? Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                        )
                      : Image.network(
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
