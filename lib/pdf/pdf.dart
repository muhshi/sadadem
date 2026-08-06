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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar2(
        title: widget.title,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              _pdfViewerController.jumpToPage(1);
            },
          ),
        ],
      ),
      body: SfPdfViewerTheme(
        data: const SfPdfViewerThemeData(
          backgroundColor: AppColors.backgroundScaffold,
        ),
        child: widget.filePath != null
            ? SfPdfViewer.file(
                File(widget.filePath!),
                controller: _pdfViewerController,
                onDocumentLoadFailed: _handleLoadFailed,
              )
            : SfPdfViewer.network(
                widget.url!,
                controller: _pdfViewerController,
                onDocumentLoadFailed: _handleLoadFailed,
              ),
      ),
    );
  }

  void _handleLoadFailed(PdfDocumentLoadFailedDetails details) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memuat PDF: ${details.description}',
            style: GoogleFonts.plusJakartaSans(),
          ),
        ),
      );
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
