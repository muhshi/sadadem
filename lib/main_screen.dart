import 'package:flutter/material.dart';
import 'package:Dalem/components/bottom_nav.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/model/download.dart';
import 'package:Dalem/kbli/kbli_main_page.dart';

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
    KbliMainPage(showBottomNav: false),
    Publikasi(showBottomNav: false),
    DownloadedPublicationsPage(showBottomNav: false),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          _onTabTapped(0);
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: _pages.asMap().entries.map((entry) {
            final index = entry.key;
            final page = entry.value;
            final isSelected = index == _currentIndex;

            return IgnorePointer(
              ignoring: !isSelected,
              child: AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: page,
              ),
            );
          }).toList(),
        ),
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
