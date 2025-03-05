import 'package:Dalem/components/bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerFromUrl extends StatefulWidget {
  final String url;
  final String title;

  const PDFViewerFromUrl({super.key, required this.url, required this.title});

  @override
  _PDFViewerFromUrlState createState() => _PDFViewerFromUrlState();
}

class _PDFViewerFromUrlState extends State<PDFViewerFromUrl> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar2(
        title: widget.title,
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.url,
            enableSwipe: true,
            swipeHorizontal: false, // Change to false for vertical swipe
            autoSpacing: false,
            pageFling: false,
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages!;
                _isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                _errorMessage = '$page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              pdfViewController.setPage(_currentPage);
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
            },
          ),
          _errorMessage.isEmpty
              ? !_isReady
                  ? Center(child: CircularProgressIndicator())
                  : Container()
              : Center(child: Text(_errorMessage)),
          Positioned(
            bottom: 10,
            left: 10,
            child: Text('Page ${_currentPage + 1} of $_totalPages'),
          ),
        ],
      ),
    );
  }
}

class PDFViewerFromFile extends StatefulWidget {
  final String filePath;
  final String title;

  const PDFViewerFromFile({super.key, required this.filePath, required this.title});

  @override
  _PDFViewerFromFileState createState() => _PDFViewerFromFileState();
}

class _PDFViewerFromFileState extends State<PDFViewerFromFile> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar2(
        title: widget.title,
      ),
      body: Stack(  
        children: [
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: false, // Change to false for vertical swipe
            autoSpacing: false,
            pageFling: false,
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages!;
                _isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                _errorMessage = '$page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              pdfViewController.setPage(_currentPage);
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
            },
          ),
          _errorMessage.isEmpty
              ? !_isReady
                  ? Center(child: CircularProgressIndicator())
                  : Container()
              : Center(child: Text(_errorMessage)),
          Positioned(
            bottom: 10,
            left: 10,
            child: Text('Page ${_currentPage + 1} of $_totalPages'),
          ),
        ],
      ),
    );
  }
}
