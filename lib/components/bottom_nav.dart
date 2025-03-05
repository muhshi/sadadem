// import 'package:Dalem/berita/berita.dart';
// import 'package:Dalem/model/search_page.dart';
// import 'package:Dalem/publikasi/downloaded_publications.dart';
// import 'package:Dalem/subject/homepage.dart';
// import 'package:flutter/material.dart';

// class BottomNav extends StatefulWidget {
//   final int selectedIndex;
//   final bool isBackHome;
//   const BottomNav({super.key, this.selectedIndex = 0, this.isBackHome = false});

//   @override
//   BottomNavState createState() => BottomNavState();
// }

// class BottomNavState extends State<BottomNav> {
//   late int _selectedIndex;
//   late bool _isBackHome;

//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.selectedIndex;
//     _isBackHome = widget.isBackHome;
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });

//     switch (index) {
//       case 0:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => Homepage()),
//         );
//         break;
//       case 1:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SearchPage(autofocus: false)),
//         );
//         break;
//       case 2:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => Berita()),
//         );
//         break;
//       case 3:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => DownloadedPublicationsPage()),
//         );
//         break;
//     }
//   }

//   Future<bool> _onWillPop() async {
//     if (_isBackHome && _selectedIndex != 0) {
//       _onItemTapped(0);
//       return false;
//     } else if (Navigator.canPop(context)) {
//       Navigator.pop(context);
//       return false;
//     }
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: BottomNavigationBar(
//         showUnselectedLabels: true,
//         backgroundColor: Colors.white,
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Beranda',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: 'Cari',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.newspaper),
//             label: 'Berita',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.download),
//             label: 'Unduhan',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue.shade800,
//         unselectedItemColor: Colors.grey,
//         selectedLabelStyle: TextStyle(color: Colors.blue.shade800),
//         unselectedLabelStyle: TextStyle(color: Colors.grey),
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }