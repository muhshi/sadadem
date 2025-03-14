// import 'package:Dalem/berita/berita.dart';
// import 'package:Dalem/components/home_ber.dart';
// import 'package:Dalem/components/home_info.dart';
// import 'package:Dalem/publikasi/downloaded_publications.dart';
// import 'package:Dalem/subcat/listDetail.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:Dalem/components/appbar.dart';
// import 'package:Dalem/components/home_pub.dart';
// import 'package:Dalem/model/search_page.dart';
// import 'package:Dalem/publikasi/publikasi.dart';
// import 'package:Dalem/strategis/strategis.dart';
// import 'package:Dalem/infographic/infographic.dart';
// import 'package:url_launcher/url_launcher.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   _HomepageState createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   final List<Map<String, dynamic>> staticData = const [
//     {"subcat_id": 514, "title": "Statistik Demografi dan Sosial"},
//     {"subcat_id": 516, "title": "Statistik Lingkungan Hidup dan Multi-domain"},
//     {"subcat_id": 515, "title": "Statistik Ekonomi"}
//   ];

//   List<Map<String, dynamic>> homeListData = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchHomeListData();
//   }

//   Future<void> fetchHomeListData() async {
//     final response = await http.get(Uri.parse(
//         'https://webapi.bps.go.id/v1/api/list/model/publication/lang/ind/domain/3321/perpage/4/key/b73ea5437eb23fb8309858b840029da2/'));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         homeListData =
//             List<Map<String, dynamic>>.from(data['data'][1]).take(1).toList();
//       });
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Colors.white,
//         child: CustomScrollView(
//           slivers: [
//             SliverList(
//               delegate: SliverChildListDelegate(
//                 [
//                   CustomAppBar(),
//                   Padding(
//                     padding: const EdgeInsets.only(
//                         top: 15, left: 10, right: 10, bottom: 10),
//                     child: SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => SearchPage(
//                                       autofocus: true,
//                                     )),
//                           );
//                         },
//                         borderRadius: BorderRadius.circular(10),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: const Color.fromARGB(255, 230, 230, 230),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: const [
//                               Padding(
//                                 padding: EdgeInsets.only(left: 16.0),
//                                 child: Text(
//                                   'Cari Data',
//                                   style: TextStyle(
//                                     color: Colors.black54,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.only(right: 16.0),
//                                 child:
//                                     Icon(Icons.search, color: Colors.black54),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   ListView(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 6),
//                         child: _buildStatisticCategory(
//                           title: 'Data Strategis',
//                           color: Colors.black87,
//                           icon: Icons.insert_chart,
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => Strategis(
//                                   title: 'Data Strategis',
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       ...staticData.asMap().entries.map((entry) {
//                         int index = entry.key;
//                         Map<String, dynamic> item = entry.value;

//                         Color boxColor;
//                         IconData icon;

//                         if (index % 3 == 0) {
//                           boxColor = Colors.blue.shade600;
//                           icon = Icons.people;
//                         } else if (index % 3 == 1) {
//                           boxColor = Colors.orange.shade600;
//                           icon = Icons.eco;
//                         } else {
//                           boxColor = Colors.green.shade600;
//                           icon = Icons.attach_money;
//                         }

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 6),
//                           child: _buildStatisticCategory(
//                             title: item['title'],
//                             color: boxColor,
//                             icon: icon,
//                             onTap: () => {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ListDetail(
//                                     id: item['subcat_id'],
//                                     title: item['title'],
//                                     color: boxColor,
//                                   ),
//                                 ),
//                               ),
//                             },
//                           ),
//                         );
//                       }),
//                       const SizedBox(height: 20),
//                       HomePublication(
//                         title: 'Publikasi Terbaru',
//                         data: homeListData,
//                         onSeeAll: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => Publikasi(),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 20),
//                       HomeInfo(
//                         title: 'Informasi Terbaru',
//                         onSeeAll: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => Infographic(),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 20),
//                       Homeberita(
//                         title: 'Berita Kegiatan BPS',
//                         onSeeAll: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => Berita(),
//                             ),
//                           );
//                         },
//                       ),
//                       Center(
//                         child: TextButton(
//                           onPressed: () {
//                             launchUrl(Uri.parse(
//                                 'https://ppid.bps.go.id/app/konten/3321/Profil-BPS.html?_gl=1*9iomf9*_ga*ODk0Njg5NDUyLjE3MzMzNjI0NDI.*_ga_XXTTVXWHDB*MTc0MDM2MTk3My40My4xLjE3NDAzNjIyODcuMC4wLjA.'));
//                           },
//                           child: const Text(
//                             'Hak Cipta © 2025 Badan Pusat Statistik',
//                             style: TextStyle(
//                               color: Colors.black54,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
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
//             icon: Icon(Icons.file_open),
//             label: 'Publikasi',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.download),
//             label: 'Unduhan',
//           ),
//         ],
//         currentIndex: 0,
//         selectedItemColor: Colors.blue.shade900,
//         unselectedItemColor: Colors.grey.shade700,
//         onTap: (index) {
//           switch (index) {
//             case 0:
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => Homepage()),
//               );
//               break;
//             case 1:
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => SearchPage(autofocus: false)),
//               );
//               break;
//             case 2:
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => Publikasi()),
//               );
//               break;
//             case 3:
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => DownloadedPublicationsPage()),
//               );
//               break;
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildStatisticCategory({
//     required String title,
//     required Color color,
//     required IconData icon,
//     VoidCallback? onTap,
//   }) {
//     return Card(
//       color: color,
//       margin: const EdgeInsets.symmetric(vertical: 0),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//           child: Row(
//             children: [
//               Icon(
//                 icon,
//                 size: 25,
//                 color: Colors.white,
//               ),
//               const SizedBox(width: 15),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       textAlign: TextAlign.left,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 color: Colors.white,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
