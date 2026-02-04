import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/pdf/pdf.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../model/download.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/components/notification_service.dart';

// The duplicate class block is removed. Only keep one definition of DetailPublikasi and DetailPublikasiState.

class DetailPublikasi extends StatefulWidget {
  final Map<String, dynamic> publication;

  const DetailPublikasi({super.key, required this.publication});

  @override
  DetailPublikasiState createState() => DetailPublikasiState();
}

class DetailPublikasiState extends State<DetailPublikasi> {
  late Future<void> initialization;
  String localFilePath = 'Lokasi default'; // You can update this after download
  bool isDownloaded = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    initialization = _checkIfDownloaded();
  }

  Future<void> _checkIfDownloaded() async {
    try {
      final directory = Directory('/storage/emulated/0/Download/Dalem');
      final cleanTitle =
          widget.publication['title'].replaceAll(RegExp(r'[^\w\s\-]'), '');
      final filePath = '${directory.path}/$cleanTitle.pdf';
      final file = File(filePath);

      if (await file.exists()) {
        if (mounted) {
          setState(() {
            isDownloaded = true;
            localFilePath = filePath;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking file existence: $e');
    }
  }

  Future<void> _savePdfWithFileSaver(
      BuildContext context, String url, String title) async {
    // Cek izin penyimpanan
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt < 33) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Izin penyimpanan diperlukan')),
              );
            }
            return;
          }
        }
      }
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final notificationService = NotificationService();

    try {
      // Tentukan direktori penyimpanan (sesuai dengan download.dart)
      final directory = Directory('/storage/emulated/0/Download/Dalem');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Bersihkan nama file
      final cleanTitle = title.replaceAll(RegExp(r'[^\w\s\-]'), '');
      final filePath = '${directory.path}/$cleanTitle.pdf';
      final file = File(filePath);

      // Mulai download
      final response =
          await http.Client().send(http.Request('GET', Uri.parse(url)));

      if (response.statusCode == 200) {
        final totalLength = response.contentLength ?? 0;
        int received = 0;
        final List<int> bytes = [];

        final stream = response.stream;
        await for (var chunk in stream) {
          bytes.addAll(chunk);
          await notificationService.showProgressNotification(
            id: notificationId,
            title: 'Mengunduh Publikasi',
            body: title,
            progress: received,
            maxProgress: totalLength,
          );
          received += chunk.length;
          if (totalLength > 0) {
            setState(() {
              _downloadProgress = received / totalLength;
            });
          }
        }

        await file.writeAsBytes(bytes);

        // Download Cover Image
        try {
          String coverUrl = widget.publication['cover'];
          if (coverUrl.isNotEmpty) {
            final coverResponse = await http.get(Uri.parse(coverUrl));
            if (coverResponse.statusCode == 200) {
              String ext = '.jpg';
              if (coverUrl.toLowerCase().endsWith('.png')) ext = '.png';
              if (coverUrl.toLowerCase().endsWith('.jpeg')) ext = '.jpeg';

              final coverPath = '${directory.path}/$cleanTitle$ext';
              final coverFile = File(coverPath);
              await coverFile.writeAsBytes(coverResponse.bodyBytes);
            }
          }
        } catch (e) {
          debugPrint('Gagal mengunduh cover: $e');
        }

        setState(() {
          isDownloaded = true;
          localFilePath = filePath;
        });
        if (mounted) {
          await notificationService.showCompleteNotification(
            id: notificationId,
            title: 'Unduhan Berhasil',
            body: '$title telah diunduh.',
            filePath: filePath,
          );
        }
      } else {
        throw Exception('Gagal mengunduh: ${response.statusCode}');
      }
    } catch (e) {
      await notificationService.showFailedNotification(
          id: notificationId,
          title: 'Unduhan Gagal',
          body: 'Gagal mengunduh $title: $e');
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _showDownloadLocation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Lokasi Penyimpanan'),
          content: Text('File disimpan di: $localFilePath'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup'),
            ),
            TextButton(
                onPressed: _navigateToDownloadsPage, child: Text('Lihat'))
          ],
        );
      },
    );
  }

  void _navigateToDownloadsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadedPublicationsPage(
          isBackHome: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar2(
              title: 'Detail Publikasi',
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar2(
              title: 'Detail Publikasi',
            ),
            body: Center(
              child: Text('Error initializing: ${snapshot.error}'),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar2(
              title: 'Detail Publikasi',
            ),
            body: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 300,
                              height: 400,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 20,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  widget.publication['cover'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey.shade200,
                                    child: Center(child: Icon(Icons.error)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.publication['title'],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dirilis pada tanggal ${widget.publication['rl_date']}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.publication['abstract'] ??
                                'No description available.',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!isDownloaded)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .blue.shade600, // Change background color
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFViewerFromUrl(
                                    url: widget.publication['pdf'],
                                    title: widget.publication['title'],
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.remove_red_eye,
                                color: Colors.white),
                            label: const Text('Lhat',
                                style: TextStyle(
                                    color: Colors.white)), // Change label
                          ),
                        if (isDownloaded)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .blue.shade600, // Change background color
                            ),
                            onPressed: _showDownloadLocation,
                            icon: const Icon(Icons.info, color: Colors.white),
                            label: const Text('Info',
                                style: TextStyle(color: Colors.white)),
                          ),
                        SizedBox(
                          width: 200,
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isDownloading
                                    ? () {}
                                    : () {
                                        if (isDownloaded) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PDFViewerFromFile(
                                                filePath: localFilePath,
                                                title:
                                                    widget.publication['title'],
                                              ),
                                            ),
                                          );
                                        } else {
                                          _savePdfWithFileSaver(
                                            context,
                                            widget.publication['pdf'],
                                            widget.publication['title'],
                                          );
                                        }
                                      },
                                icon: _isDownloading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : Icon(
                                        isDownloaded
                                            ? Icons.folder_open
                                            : Icons.download,
                                        color: Colors.white),
                                label: _isDownloading
                                    ? Text('Mengunduh...',
                                        style: TextStyle(color: Colors.white))
                                    : Text(
                                        isDownloaded ? 'Buka' : 'Download PDF',
                                        style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
      },
    );
  }
}
