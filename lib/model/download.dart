import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/components/bottom_nav.dart';
import 'package:Dalem/pdf/pdf.dart';
import 'package:Dalem/main_screen.dart';

class DownloadedPublicationsPage extends StatefulWidget {
  final bool isBackHome;
  final bool showBottomNav;
  const DownloadedPublicationsPage({
    super.key,
    this.isBackHome = true,
    this.showBottomNav = true,
  });

  @override
  DownloadedPublicationsPageState createState() =>
      DownloadedPublicationsPageState();
}

class DownloadedPublicationsPageState
    extends State<DownloadedPublicationsPage>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Map<String, String>>> _downloadedFiles;
  String _sortCriteria = 'date';
  bool _permissionGranted = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadFiles();
  }

  Future<void> _requestPermissionAndLoadFiles() async {
    if (await _requestPermission(Permission.storage)) {
      if (mounted) {
        setState(() {
          _permissionGranted = true;
          _downloadedFiles = _loadDownloadedFiles();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _permissionGranted = false;
          _downloadedFiles = Future.value([]);
        });
      }
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
    // Di web, permission storage tidak diperlukan
    if (kIsWeb) return true;
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
    // Di web, filesystem lokal tidak tersedia
    if (kIsWeb) return [];
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: AppColors.backgroundScaffold,
        appBar: AppBar2(
          title: 'File Unduhan',
          showBackButton: false,
          actions: [
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: AppColors.primaryNavy,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortCriteria,
                icon: const Icon(Icons.sort_rounded, color: Colors.white, size: 20),
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                items: [
                  DropdownMenuItem(
                    value: 'date',
                    child: Text('Terbaru', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: 'name',
                    child: Text('Nama (A-Z)', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: 'size',
                    child: Text('Ukuran Terbesar', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortCriteria = value!;
                    _downloadedFiles = _loadDownloadedFiles();
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _permissionGranted
          ? FutureBuilder<List<Map<String, String>>>(
              future: _downloadedFiles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoading();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat file: ${snapshot.error}',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.accentRose),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                } else {
                  final files = snapshot.data!;
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(14.0),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = File(files[index]['file']!);
                      final coverFile = File(files[index]['cover']!);
                      final hasCover = files[index]['cover']!.isNotEmpty &&
                          coverFile.existsSync();
                      final fileType = _getFileType(file);
                      final fileName = file.path.split('/').last;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppColors.cardShadow,
                          border: Border.all(color: AppColors.borderDefault),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              if (file.path.endsWith('.pdf')) {
                                final deviceInfo = DeviceInfoPlugin();
                                final androidInfo =
                                    await deviceInfo.androidInfo;
                                if (!kIsWeb &&
                                    Platform.isAndroid &&
                                    androidInfo.version.sdkInt >= 33 &&
                                    !_permissionGranted) {
                                  _pickPdfFile();
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PDFViewerFromFile(
                                          filePath: file.path,
                                          title: fileName),
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
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: hasCover
                                        ? Image.file(
                                            coverFile,
                                            width: 55,
                                            height: 55,
                                            fit: BoxFit.cover,
                                          )
                                        : _buildFileTypeIcon(file.path),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getFileTypeColor(file.path)
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            fileType,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: _getFileTypeColor(file.path),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          fileName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded,
                                        color: AppColors.textMuted),
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
                                        child: Row(
                                          children: [
                                            Icon(Icons.open_in_new_rounded,
                                                size: 18, color: AppColors.primaryNavy),
                                            const SizedBox(width: 8),
                                            Text('Buka dengan',
                                                style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'details',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.info_outline_rounded,
                                                size: 18, color: AppColors.textSecondary),
                                            const SizedBox(width: 8),
                                            Text('Informasi',
                                                style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.delete_outline_rounded,
                                                size: 18, color: AppColors.accentRose),
                                            const SizedBox(width: 8),
                                            Text('Hapus',
                                                style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 13, color: AppColors.accentRose)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            )
          : _buildPermissionDeniedState(),
      bottomNavigationBar: widget.showBottomNav
          ? const BottomNav(currentIndex: 3)
          : null,
    );
  }

  Widget _buildFileTypeIcon(String path) {
    if (path.endsWith('.pdf')) {
      return Container(
        width: 55,
        height: 55,
        color: AppColors.accentRose.withValues(alpha: 0.1),
        child: const Icon(Icons.picture_as_pdf_rounded,
            size: 28, color: AppColors.accentRose),
      );
    } else if (path.endsWith('.xls') || path.endsWith('.xlsx')) {
      return Container(
        width: 55,
        height: 55,
        color: Colors.green.withValues(alpha: 0.1),
        child: const Icon(Icons.table_view_rounded,
            size: 28, color: Colors.green),
      );
    } else {
      return Container(
        width: 55,
        height: 55,
        color: AppColors.accentTeal.withValues(alpha: 0.1),
        child: const Icon(Icons.image_rounded,
            size: 28, color: AppColors.accentTeal),
      );
    }
  }

  Color _getFileTypeColor(String path) {
    if (path.endsWith('.pdf')) {
      return AppColors.primaryNavy;
    } else if (path.endsWith('.xls') || path.endsWith('.xlsx')) {
      return Colors.green.shade700;
    } else {
      return AppColors.accentTeal;
    }
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
        return 'Tabel Statistik';
      default:
        return 'File';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_download_rounded,
              size: 64,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada File Terunduh',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'File publikasi, tabel, atau infografis\nyang diunduh akan muncul di sini',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_off_rounded,
                size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'Akses Penyimpanan Terbatas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Berikan izin penyimpanan untuk melihat daftar unduhan Anda',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _requestPermissionAndLoadFiles,
              icon: const Icon(Icons.security_rounded, size: 18),
              label: Text('Berikan Izin',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickPdfFile,
              icon: const Icon(Icons.folder_open_rounded, size: 18),
              label: Text('Buka File Manual',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        );
      },
    );
  }

  void showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
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
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
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
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Informasi File',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Nama', file.path.split('/').last),
              _buildDetailRow('Ukuran', '${(stat.size / 1024).toStringAsFixed(1)} KB'),
              _buildDetailRow('Tipe', _getFileType(file)),
              _buildDetailRow('Lokasi', file.path),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
              ),
              child: Text('Tutup',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFile(int index, List<Map<String, String>> files) async {
    final filePath = files[index]['file'];
    final coverPath = files[index]['cover'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus File',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus file ini dari perangkat?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRose,
            ),
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
                if (mounted) {
                  Navigator.of(context).pop();
                  setState(() {
                    _downloadedFiles = _loadDownloadedFiles();
                  });
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus file: $e')),
                  );
                }
              }
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
