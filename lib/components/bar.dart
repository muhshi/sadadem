import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/main_screen.dart';

class AppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppBar2({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.subAppBarGradient,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        actions: actions ?? [],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    if (onBackPressed != null) {
                      onBackPressed!();
                    } else if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      // Fallback aman: Arahkan ke Beranda / MainScreen index 0
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MainScreen(initialIndex: 0),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              )
            : null,
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
