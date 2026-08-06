import 'dart:io';
import 'package:Dalem/components/bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class PDFViewerFromUrl extends StatefulWidget {
  final String url;
  final String title;

  const PDFViewerFromUrl({super.key, required this.url, required this.title});

  @override
  PDFViewerFromUrlState createState() => PDFViewerFromUrlState();
}

class PDFViewerFromUrlState extends State<PDFViewerFromUrl> {
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
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
          backgroundColor: Color(0xFFF8F9FB),
        ),
        child: SfPdfViewer.network(
          widget.url,
          controller: _pdfViewerController,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Gagal memuat PDF: ${details.description}',
                  style: GoogleFonts.plusJakartaSans(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PDFViewerFromFile extends StatefulWidget {
  final String filePath;
  final String title;

  const PDFViewerFromFile({super.key, required this.filePath, required this.title});

  @override
  PDFViewerFromFileState createState() => PDFViewerFromFileState();
}

class PDFViewerFromFileState extends State<PDFViewerFromFile> {
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
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
          backgroundColor: Color(0xFFF8F9FB),
        ),
        child: SfPdfViewer.file(
          File(widget.filePath),
          controller: _pdfViewerController,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Gagal memuat PDF: ${details.description}',
                  style: GoogleFonts.plusJakartaSans(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
