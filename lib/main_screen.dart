import 'package:flutter/material.dart';
import 'package:Dalem/components/bottom_nav.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/model/download.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    Homepage(showBottomNav: false),
    SearchPage(autofocus: false, showBottomNav: false),
    Publikasi(showBottomNav: false),
    DownloadedPublicationsPage(showBottomNav: false),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
