import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/model/download.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
          ),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.search,
          ),
          label: 'Cari',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.file_open,
          ),
          label: 'Publikasi',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.download,
          ),
          label: 'Unduhan',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.grey.shade700,
      unselectedItemColor: Colors.grey.shade700,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Homepage()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchPage(autofocus: false)),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Publikasi()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DownloadedPublicationsPage()),
            );
            break;
        }
      },
      elevation: 8.0,
    );
  }
}