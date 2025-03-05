import 'package:flutter/material.dart';

class AppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AppBar2({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: actions ?? [],
      backgroundColor: Colors.blue.shade900, // Changed color to blue
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
        // onPressed: () {
        //   Navigator.pop(context);
        // },
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
