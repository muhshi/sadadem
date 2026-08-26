import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/main_screen.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNav({super.key, required this.currentIndex, this.onTap});

  void _navigateToTab(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    if (index == currentIndex) return;

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            MainScreen(initialIndex: index),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = (currentIndex < 0 || currentIndex > 3) ? 0 : currentIndex;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        boxShadow: AppColors.cardShadow,
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppColors.navIndicator,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navSelected,
              );
            }
            return GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.navUnselected,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.navSelected, size: 24);
            }
            return const IconThemeData(color: AppColors.navUnselected, size: 24);
          }),
        ),
        child: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: (index) {
            _navigateToTab(context, index);
          },
          backgroundColor: AppColors.surfaceCard,
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