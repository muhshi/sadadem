import 'package:Dalem/components/bar.dart';
import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/pdf/pdf.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';

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

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'xls', 'xlsx'],
    );
    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      await OpenFile.open(filePath);
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final images = await Permission.photos.request();
        return images.isGranted;
      } else {
        final result = await permission.request();
        return result == PermissionStatus.granted;
      }
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
    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) =>
            file.path.endsWith('.pdf') ||
            file.path.endsWith('.jpg') ||
            file.path.endsWith('.jpeg') ||
            file.path.endsWith('.png') ||
            file.path.endsWith('.xls') ||
            file.path.endsWith('.xlsx'))
        .toList();

    List<Map<String, String>> fileList = [];
    for (var file in files) {
      // Cek apakah file gambar ini merupakan cover dari file PDF/Excel yang ada
      if (file.path.endsWith('.jpg') ||
          file.path.endsWith('.jpeg') ||
          file.path.endsWith('.png')) {
        final baseName = file.path.substring(0, file.path.lastIndexOf('.'));
        if (File('$baseName.pdf').existsSync() ||
            File('$baseName.xls').existsSync() ||
            File('$baseName.xlsx').existsSync()) {
          continue;
        }
      }

      String coverPath = '';
      // Cek cover untuk semua tipe file (termasuk PDF)
      final baseName = file.path.substring(0, file.path.lastIndexOf('.'));
      for (var ext in ['.jpg', '.jpeg', '.png']) {
        final possibleCover = File('$baseName$ext');
        if (possibleCover.existsSync() && possibleCover.path != file.path) {
          coverPath = possibleCover.path;
          break;
        }
      }
      fileList.add({'file': file.path, 'cover': coverPath});
    }

    // Sort files based on _sortCriteria
    if (_sortCriteria == 'date') {
      fileList.sort((a, b) {
        final aFile = File(a['file']!);
        final bFile = File(b['file']!);
        return bFile.lastModifiedSync().compareTo(aFile.lastModifiedSync());
      });
    } else if (_sortCriteria == 'name') {
      fileList.sort((a, b) =>
          a['file']!.toLowerCase().compareTo(b['file']!.toLowerCase()));
    } else if (_sortCriteria == 'size') {
      fileList.sort((a, b) {
        final aFile = File(a['file']!);
        final bFile = File(b['file']!);
        return bFile.lengthSync().compareTo(aFile.lengthSync());
      });
    }

    return fileList;
  }

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
                        final hasCover = files[index]['cover']!.isNotEmpty &&
                            coverFile.existsSync();
                        final fileType = _getFileType(file);
                        return ListTile(
                          leading: hasCover
                              ? Image.file(
                                  coverFile,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : file.path.endsWith('.pdf')
                                  ? Icon(Icons.picture_as_pdf,
                                      size: 50, color: Colors.red)
                                  : file.path.endsWith('.xls') ||
                                          file.path.endsWith('.xlsx')
                                      ? Icon(Icons.insert_drive_file,
                                          size: 50, color: Colors.green)
                                      : Image.file(
                                          file,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
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
                          onTap: () async {
                            if (file.path.endsWith('.pdf')) {
                              // Untuk Android 13+, jika permission denied, pakai file picker
                              final deviceInfo = DeviceInfoPlugin();
                              final androidInfo = await deviceInfo.androidInfo;
                              if (Platform.isAndroid &&
                                  androidInfo.version.sdkInt >= 33 &&
                                  !_permissionGranted) {
                                _pickPdfFile();
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PDFViewerFromFile(
                                        filePath: file.path,
                                        title: file.path.split('/').last),
                                  ),
                                );
                              }
                            } else if (file.path.endsWith('.xls') ||
                                file.path.endsWith('.xlsx')) {
                              await OpenFile.open(file.path);
                            } else {
                              showFullScreenImage(context, file.path);
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
                    Text('Izin penyimpanan tidak diberikan atau tidak tersedia',
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _requestPermissionAndLoadFiles,
                      child: Text('Izinkan'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _pickPdfFile,
                      icon: Icon(Icons.folder_open),
                      label: Text('Buka File (PDF, Gambar, Tabel)'),
                    ),
                  ],
                ),
              ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     final directory = Directory('/storage/emulated/0/Download/Dalem/');
      //     if (await directory.exists()) {
      //       await OpenFile.open(directory.path);
      //     } else {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(content: Text('Directory does not exist')),
      //       );
      //     }
      //   },
      //   backgroundColor: Colors.blue.shade600,
      //   tooltip: 'Buka dengan',
      //   child: Icon(Icons.folder, color: Colors.white),
      // ),
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

  String _getFileType(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'Publikasi';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'Infografik';
      case 'xls':
      case 'xlsx':
        return 'Table';
      default:
        return 'Unknown';
    }
  }

  void showFullScreenImage(BuildContext context, String imagePath) {
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

  void _showFileDetails(File file) async {
    final stat = await file.stat();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Info File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama: ${file.path.split('/').last}'),
              Text('Ukuran: ${stat.size} bytes'),
              Text('Tipe: ${_getFileType(file)}'),
              Text('Terakhir diubah: ${stat.modified}'),
              Text('Path: ${file.path}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteFile(int index, List<Map<String, String>> files) async {
    final filePath = files[index]['file'];
    final coverPath = files[index]['cover'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus File'),
        content: Text('Apakah Anda yakin ingin menghapus file ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (filePath != null && File(filePath).existsSync()) {
                  await File(filePath).delete();
                }
                if (coverPath != null &&
                    coverPath.isNotEmpty &&
                    File(coverPath).existsSync()) {
                  await File(coverPath).delete();
                }
                Navigator.of(context).pop();
                setState(() {
                  _downloadedFiles = _loadDownloadedFiles();
                });
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus file: $e')),
                );
              }
            },
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
