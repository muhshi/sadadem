import 'dart:io';

import 'package:Dalem/components/bar.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar2(
        title: widget.title,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _pdfViewerController.jumpToPage(1); // Reset to the first page
            },
          ),
        ],
      ),
      body: SfPdfViewerTheme(
        data: SfPdfViewerThemeData(
          backgroundColor: Colors.white,
        ),
        child: SfPdfViewer.network(
          widget.url,
          controller: _pdfViewerController,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal memuat PDF: ${details.description}')),
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
      appBar: AppBar2(
        title: widget.title,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _pdfViewerController.jumpToPage(1); // Reset to the first page
            },
          ),
        ],
      ),
      body: SfPdfViewerTheme(
        data: SfPdfViewerThemeData(
          backgroundColor: Colors.white,
        ),
        child: SfPdfViewer.file(
          File(widget.filePath),
          controller: _pdfViewerController,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal memuat PDF: ${details.description}')),
            );
          },
        ),
      ),
    );
  }
}
