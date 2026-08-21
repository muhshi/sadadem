import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/components/full_screen_image_viewer.dart';
import 'package:Dalem/config/api_config.dart';
import 'package:Dalem/utils/permission_helper.dart';

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
    if (await PermissionHelper.requestStoragePermission()) {
      if (mounted) {
        setState(() {
          _permissionGranted = true;
        });
      }
      _downloadedFiles = await _loadDownloadedFiles();
    } else {
      if (mounted) {
        setState(() {
          _permissionGranted = false;
        });
      }
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
            item.path.endsWith('.jpeg') ||
            item.path.endsWith('.png'))
        .map((item) => {
              'title': item.path.split('/').last.replaceFirst(RegExp(r'\.[^.]+$'), ''),
              'image': item.path,
            })
        .toList();
    return files;
  }

  Future<void> fetchInfographic() async {
    setState(() {
      isLoading = true;
    });

    final url = ApiConfig.listUrl(
        model: 'infographic', page: currentPage, perpage: 10);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final newInfographic = jsonResponse['data'][1];

      if (mounted) {
        setState(() {
          infographicList.addAll(newInfographic);
          currentPage++;
          isLoading = false;
          hasMoreData = newInfographic.length == 10;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      currentPage = 1;
      infographicList = [];
      hasMoreData = true;
    });
    await fetchInfographic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: const AppBar2(
        title: 'Daftar Infografis',
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primaryNavy,
        backgroundColor: Colors.white,
        child: infographicList.isEmpty && isLoading
            ? _buildShimmerGrid()
            : GridView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(12.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
              itemCount: infographicList.length + (hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == infographicList.length) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }
                var item = infographicList[index];
                bool isDownloaded = _downloadedFiles
                    .any((file) => file['title'] == item['title']);
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? 'Infografis',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GestureDetector(
                              onTap: () {
                                var info = item;
                                FullScreenImageViewer.show(
                                    context, info['img']!, isFile: false);
                              },
                              child: CachedNetworkImage(
                                imageUrl: item['img'],
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: Icon(Icons.broken_image_rounded,
                                        color: AppColors.textMuted),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: ElevatedButton.icon(
                            icon: Icon(
                              isDownloaded
                                  ? Icons.visibility_rounded
                                  : Icons.download_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              isDownloaded ? 'Buka' : 'Unduh',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDownloaded
                                  ? AppColors.primaryLight
                                  : AppColors.primaryNavy,
                              padding: EdgeInsets.zero,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              if (isDownloaded) {
                                var info = _downloadedFiles.firstWhere(
                                    (file) => file['title'] == item['title']);
                                FullScreenImageViewer.show(
                                    context, info['image']!, isFile: true);
                              } else {
                                _downloadImage(
                                    context, item['img'], item['title']);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadImage(
      BuildContext context, String url, String title) async {
    if (await PermissionHelper.requestStoragePermission()) {
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

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.accentTeal, size: 26),
                    const SizedBox(width: 8),
                    Text(
                      'Unduhan Berhasil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'File infografis berhasil disimpan di:\n$filePath',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    ),
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
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengunduh gambar: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin penyimpanan ditolak')),
        );
      }
    }
  }
}
