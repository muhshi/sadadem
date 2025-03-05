
import 'package:Dalem/components/bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFViewerFromUrl extends StatelessWidget {
  final String url;
  final String title;

  const PDFViewerFromUrl({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar2(
        title: title,
      ),
      body: PDF().cachedFromUrl(
        url,
        placeholder: (double progress) => Center(child: Text('Memuat $progress %')),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class PDFViewerFromFile extends StatelessWidget {
  final String filePath;
  final String title;

  const PDFViewerFromFile({super.key, required this.filePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar2(
        title: title,
      ),
      body: PDF().fromPath(
        filePath,
      ),
    );
  }
}
