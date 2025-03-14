import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/pdf/pdf.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:Dalem/components/bar.dart';
import '../model/download.dart';

class DetailPublikasi extends StatefulWidget {
  final Map<String, dynamic> publication;

  const DetailPublikasi({super.key, required this.publication});

  @override
  _DetailPublikasiState createState() => _DetailPublikasiState();
}

class _DetailPublikasiState extends State<DetailPublikasi> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  late String _localFilePath;
  late String _localCoverPath;
  bool _isDownloaded = false;
  late Future<void> _initialization;
  List<Map<String, String>> _downloadedFiles = [];

  @override
  void initState() {
    super.initState();
    _initialization = _initializeLocalFilePath();
    _loadDownloadedFiles();
  }

  Future<void> _initializeLocalFilePath() async {
    if (await _requestPermission(Permission.storage)) {
      final directory = Directory('/storage/emulated/0/Download/Dalem');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      _localFilePath = '${directory.path}/${widget.publication['title']}.pdf';

      final documentDir = await getApplicationDocumentsDirectory();
      _localCoverPath =
          '${documentDir.path}/${widget.publication['title']}_cover.jpg';

      await _checkIfDownloaded();
      await _loadDownloadedFiles(); // Refresh the loaded files after permission is granted
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied')),
      );
    }
  }

  Future<void> _checkIfDownloaded() async {
    final file = File(_localFilePath);
    if (await file.exists()) {
      setState(() {
        _isDownloaded = true;
      });
    }
  }

  Future<void> _loadDownloadedFiles() async {
    if (await _requestPermission(Permission.storage)) {
      final directory = Directory('/storage/emulated/0/Download/Dalem');
      final files = directory
          .listSync()
          .where((item) => item.path.endsWith('.pdf'))
          .map((item) {
        final coverPath = item.path.replaceAll('.pdf', '_cover.jpg');
        return {
          'pdf': item.path,
          'cover': coverPath,
        };
      }).toList();
      setState(() {
        _downloadedFiles = files;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied')),
      );
    }
  }

  Future<void> _downloadPDF(
      BuildContext context, String url, String coverUrl) async {
    if (await _requestPermission(Permission.storage)) {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      try {
        final file = File(_localFilePath);
        final coverFile = File(_localCoverPath);

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

        await Dio().download(coverUrl, coverFile.path);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Unduhan Berhasil'),
              content: Text('File disimpan di: $_localFilePath'),
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
          _isDownloaded = true;
          _downloadedFiles.add({
            'pdf': file.path,
            'cover': coverFile.path,
          });
        });
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading PDF: $e')),
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

  Future<void> _movePDFToDownloads() async {
    if (await _requestPermission(Permission.storage)) {
      try {
        final directory = Directory('/storage/emulated/0/Download/Dalem');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        final newFile =
            File('${directory.path}/${widget.publication['title']}.pdf');
        final oldFile = File(_localFilePath);

        if (await oldFile.exists()) {
          await oldFile.copy(newFile.path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF moved to ${newFile.path}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF file does not exist')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error moving PDF: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied')),
      );
    }
  }

  void _showDownloadLocation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Lokasi Penyimpanan'),
          content: Text('File disimpan di: $_localFilePath'),
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
      future: _initialization,
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
                        if (!_isDownloaded)
                            ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600, // Change background color
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
                            icon: const Icon(Icons.remove_red_eye, color: Colors.white),
                            label: const Text('Lhat', style: TextStyle(color: Colors.white)), // Change label
                            ),
                            if (_isDownloaded)
                            ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600, // Change background color
                            ),
                            onPressed: _showDownloadLocation,
                            icon: const Icon(Icons.info, color: Colors.white),
                            label: const Text('Info', style: TextStyle(color: Colors.white)),
                            ),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton.icon(
                            onPressed: _isDownloading
                                ? null
                                : _isDownloaded
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PDFViewerFromFile(
                                              filePath: _localFilePath,
                                              title:
                                                  widget.publication['title'],
                                            ),
                                          ),
                                        );
                                      }
                                    : () => _downloadPDF(
                                        context,
                                        widget.publication['pdf'],
                                        widget.publication['cover']),
                                    icon: _isDownloading
                                    ? CircularProgressIndicator(
                                      value: _downloadProgress,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                      )
                                    : _isDownloaded
                                      ? const Icon(Icons.open_in_new, color: Colors.white)
                                      : const Icon(Icons.download, color: Colors.white),
                                    label: _isDownloading
                                    ? Text(
                                      '${(_downloadProgress * 100).toStringAsFixed(0)}%', style: TextStyle(color: Colors.blue.shade600))
                                    : _isDownloaded
                                      ? const Text('Buka', style: TextStyle(color: Colors.white))
                                      : Text(
                                      'Unduh (${widget.publication['size'] ?? 'unknown'})', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    ),
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
