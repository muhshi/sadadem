import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bar.dart';

/// Unified PDF Viewer supporting both remote network URLs and local file paths.
class PdfViewerPage extends StatefulWidget {
  final String title;
  final String? url;
  final String? filePath;

  const PdfViewerPage({
    super.key,
    required this.title,
    this.url,
    this.filePath,
  }) : assert(
          url != null || filePath != null,
          'Either url or filePath must be provided to PdfViewerPage',
        );

  @override
  PdfViewerPageState createState() => PdfViewerPageState();
}

class PdfViewerPageState extends State<PdfViewerPage> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Key _viewerKey = UniqueKey();

  void _reloadPdf() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _viewerKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar2(
        title: widget.title,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Muat Ulang PDF',
            onPressed: () {
              if (_hasError) {
                _reloadPdf();
              } else {
                _pdfViewerController.jumpToPage(1);
              }
            },
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!_hasError)
              Positioned.fill(
                child: RepaintBoundary(
                  child: SfPdfViewerTheme(
                    data: const SfPdfViewerThemeData(
                      backgroundColor: AppColors.backgroundScaffold,
                    ),
                    child: widget.filePath != null
                        ? SfPdfViewer.file(
                            File(widget.filePath!),
                            key: _viewerKey,
                            controller: _pdfViewerController,
                            canShowScrollHead: false, // Prevents RenderTransform hasSize layout bug
                            canShowScrollStatus: false, // Prevents RenderTransform hasSize layout bug
                            canShowPaginationDialog: false,
                            enableDoubleTapZooming: true,
                            enableTextSelection: true,
                            onDocumentLoaded: (details) {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            },
                            onDocumentLoadFailed: _handleLoadFailed,
                          )
                        : SfPdfViewer.network(
                            widget.url!,
                            key: _viewerKey,
                            controller: _pdfViewerController,
                            canShowScrollHead: false, // Prevents RenderTransform hasSize layout bug
                            canShowScrollStatus: false, // Prevents RenderTransform hasSize layout bug
                            canShowPaginationDialog: false,
                            enableDoubleTapZooming: true,
                            enableTextSelection: true,
                            onDocumentLoaded: (details) {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            },
                            onDocumentLoadFailed: _handleLoadFailed,
                          ),
                  ),
                ),
              ),

            // Loading Overlay
            if (_isLoading && !_hasError)
              Positioned.fill(
                child: Container(
                  color: AppColors.backgroundScaffold,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primaryNavy,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat Dokumen PDF...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Error State
            if (_hasError)
              Positioned.fill(
                child: Container(
                  color: AppColors.backgroundScaffold,
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 56,
                          color: AppColors.accentRose,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Gagal Membuka PDF',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage.isNotEmpty
                              ? _errorMessage
                              : 'Terjadi kesalahan saat mengunduh atau membaca file PDF.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Coba Lagi'),
                          onPressed: _reloadPdf,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleLoadFailed(PdfDocumentLoadFailedDetails details) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = details.description;
      });
    }
  }
}

/// Backward-compatibility wrappers
class PDFViewerFromUrl extends PdfViewerPage {
  const PDFViewerFromUrl({
    super.key,
    required String url,
    required String title,
  }) : super(title: title, url: url);
}

class PDFViewerFromFile extends PdfViewerPage {
  const PDFViewerFromFile({
    super.key,
    required String filePath,
    required String title,
  }) : super(title: title, filePath: filePath);
}
