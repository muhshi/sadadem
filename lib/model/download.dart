import 'dart:math';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/pdf/pdf.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadedPublicationsPage extends StatefulWidget {
  final bool isBackHome;
  const DownloadedPublicationsPage({super.key, this.isBackHome = true});

  @override
  DownloadedPublicationsPageState createState() =>
      DownloadedPublicationsPageState();
}

class DownloadedPublicationsPageState
    extends State<DownloadedPublicationsPage> {
  late Future<List<Map<String, String>>> _downloadedFiles;
  String _sortCriteria = 'name';
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadFiles();
  }

  Future<void> _requestPermissionAndLoadFiles() async {
    if (await _requestPermission(Permission.storage)) {
      setState(() {
        _permissionGranted = true;
      });
      _downloadedFiles = _loadDownloadedFiles();
    } else {
      setState(() {
        _permissionGranted = false;
      });
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

Future<List<Map<String, String>>> _loadDownloadedFiles() async {
  final directory = Directory('/storage/emulated/0/Download/Dalem');
  if (!await directory.exists()) {
    return [];
  }
  final dataDir = await getApplicationDocumentsDirectory();
  final files = directory
      .listSync()
      .where((item) =>
          item.path.endsWith('.pdf') ||
          item.path.endsWith('.jpg') ||
          item.path.endsWith('.png'))
      .map((item) {
    final coverPath = item.path.endsWith('.pdf')
        ? '${dataDir.path}/${item.path.split('/').last.replaceFirst('.pdf', '_cover.jpg')}'
        : item.path;
    return {
      'file': item.path,
      'cover': coverPath,
    };
  }).toList();
  _sortFiles(files);
  return files;
}


  void _sortFiles(List<Map<String, String>> files) {
    if (_sortCriteria == 'name') {
      files.sort((a, b) => a['file']!.compareTo(b['file']!));
    } else if (_sortCriteria == 'size') {
      files.sort((a, b) {
        final fileA = File(a['file']!);
        final fileB = File(b['file']!);
        return fileB.lengthSync().compareTo(fileA.lengthSync());
      });
    } else if (_sortCriteria == 'date') {
      files.sort((a, b) {
        final fileA = File(a['file']!);
        final fileB = File(b['file']!);
        return fileB.lastModifiedSync().compareTo(fileA.lastModifiedSync());
      });
    }
  }

  void _deleteFile(int index, List<Map<String, String>> files) async {
    final file = File(files[index]['file']!);
    final coverFile = File(files[index]['cover']!);
    if (await file.exists()) {
      await file.delete();
    }
    if (await coverFile.exists()) {
      await coverFile.delete();
    }
    setState(() {
      files.removeAt(index);
    });
  }

  void _confirmDeleteFile(int index, List<Map<String, String>> files) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus file ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteFile(index, files);
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  String _getFileType(File file) {
    if (file.path.endsWith('.pdf')) {
      return 'Publikasi';
    } else if (file.path.endsWith('.jpg') ||
        file.path.endsWith('.jpeg') ||
        file.path.endsWith('.png')) {
      return 'Infografis';
    } else {
      return 'Unknown';
    }
  }

  void _showFileDetails(File file) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(file.path.split('/').last),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lokasi: ${file.path}'),
              Text('Ukuran: ${_getFileSize(file)}'),
              Text('Tipe: ${_getFileType(file)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  //   if (index == 0) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => Homepage()),
  //     );
  //   } else if (index == 1) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => SearchPage(autofocus: false,)),
  //     );
  //   } else if (index == 2) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => DownloadedPublicationsPage()),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar2(
        title: 'Unduhan',
        actions: [
          DropdownButton<String>(
            value: _sortCriteria,
            dropdownColor: Colors.black,
            style: TextStyle(color: Colors.white),
            items: [
              DropdownMenuItem(
                value: 'date',
                child: Text('Terbaru', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'name',
                child:
                    Text('Nama (A-Z)', style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: 'size',
                child: Text('Ukuran Terbesar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _sortCriteria = value!;
                _downloadedFiles = _loadDownloadedFiles();
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: _permissionGranted
            ? FutureBuilder<List<Map<String, String>>>(
                future: _downloadedFiles,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error loading files: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_download,
                              size: 100, color: Colors.grey),
                          SizedBox(height: 20),
                          Text('Kamu belum mengunduh apapun',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  } else {
                    final files = snapshot.data!;
                    return ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = File(files[index]['file']!);
                        final coverFile = File(files[index]['cover']!);
                        final fileType = _getFileType(file);
                        return ListTile(
                          leading: coverFile.existsSync()
                              ? Image.file(
                                  coverFile,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.fitHeight,
                                )
                              : Icon(
                                  file.path.endsWith('.pdf')
                                      ? Icons.picture_as_pdf
                                      : Icons.image,
                                  size: 50,
                                  color: file.path.endsWith('.pdf')
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                          title: Text(file.path.split('/').last),
                          subtitle: Text(fileType),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'details') {
                                _showFileDetails(file);
                              } else if (value == 'delete') {
                                _confirmDeleteFile(index, files);
                              } else if (value == 'open_with') {
                                await OpenFile.open(file.path);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'open_with',
                                child: ListTile(
                                  leading: Icon(Icons.open_in_new),
                                  title: Text('Buka dengan'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'details',
                                child: ListTile(
                                  leading: Icon(Icons.info),
                                  title: Text('Info'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete),
                                  title: Text('Hapus'),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            if (file.path.endsWith('.pdf')) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFViewerFromFile(
                                      filePath: file.path,
                                      title: file.path.split('/').last),
                                ),
                              );
                            } else {
                              // showDialog(
                              //   context: context,
                              //   builder: (context) {
                              //     return AlertDialog(
                              //       content: Image.file(file),
                              //       actions: [
                              //         TextButton(
                              //           onPressed: () => Navigator.pop(context),
                              //           child: Text('Tutup'),
                              //         ),
                              //       ],
                              //     );
                              //   },
                              // );
                              _showFullScreenImage(context, file.path);
                            }
                          },
                        );
                      },
                    );
                  }
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 100, color: Colors.grey),
                    SizedBox(height: 20),
                    Text('Izin penyimpanan diperlukan untuk mengakses unduhan',
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _requestPermissionAndLoadFiles,
                      child: Text('Izinkan'),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final directory = Directory('/storage/emulated/0/Download/Dalem/');
          if (await directory.exists()) {
            await OpenFile.open(directory.path);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Directory does not exist')),
            );
          }
        },
        backgroundColor: Colors.blue.shade600,
        tooltip: 'Buka dengan',
        child: Icon(Icons.folder, color: Colors.white),
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
        currentIndex: 3, // Set the initial selected index to Downloads
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

  void _showFullScreenImage(BuildContext context, String imagePath) {
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
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                    )),
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
