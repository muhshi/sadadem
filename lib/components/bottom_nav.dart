import 'package:Dalem/model/search_page.dart';
import 'package:Dalem/model/download.dart';
import 'package:Dalem/publikasi/publikasi.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNav({super.key, required this.currentIndex, this.onTap});

  void _navigateToTab(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const Homepage();
        break;
      case 1:
        page = const SearchPage(autofocus: false);
        break;
      case 2:
        page = const Publikasi();
        break;
      case 3:
        page = const DownloadedPublicationsPage();
        break;
      default:
        page = const Homepage();
    }

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryNavy = Color(0xFF002B6A);
    const greyColor = Color(0xFF64748B);
    final safeIndex = (currentIndex < 0 || currentIndex > 3) ? 0 : currentIndex;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: primaryNavy.withOpacity(0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primaryNavy,
              );
            }
            return GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: greyColor,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: primaryNavy, size: 24);
            }
            return const IconThemeData(color: greyColor, size: 24);
          }),
        ),
        child: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: (index) {
            if (onTap != null) {
              onTap!(index);
            }
            _navigateToTab(context, index);
          },
          backgroundColor: Colors.white,
          elevation: 0,
          height: 65,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Cari',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Publikasi',
            ),
            NavigationDestination(
              icon: Icon(Icons.file_download_outlined),
              selectedIcon: Icon(Icons.file_download_rounded),
              label: 'Unduhan',
            ),
          ],
        ),
      ),
    );
  }
}