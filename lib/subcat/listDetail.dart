// import 'dart:convert';
// import 'package:Dalem/components/bottom_nav.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:Dalem/cat/catdetail.dart';
// import 'package:Dalem/components/bar.dart';
// import 'package:Dalem/components/offline_storage.dart';

// class ListDetail extends StatelessWidget {
//   final int id;
//   final String title;
//   final Color color;

//   const ListDetail(
//       {super.key, required this.id, required this.title, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar2(
//         title: title,
//       ),
//       backgroundColor: Colors.white,
//       body: FutureBuilder<List<dynamic>>(
//         future: fetchData(
//             'https://webapi.bps.go.id/v1/api/list/domain/3321/model/subjectcsa/subcat/$id/perpage/20/key/b73ea5437eb23fb8309858b840029da2/'),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No data available'));
//           } else {
//             return Container(
//               color: Colors.white,
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: snapshot.data!.length,
//                         itemBuilder: (context, index) {
//                           var item = snapshot.data![index];

//                           return _buildStatisticCategory(
//                             icon: Icons.folder_copy_outlined,
//                             title: item['title'],
//                             color: color, // Changed color to blue
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => Catdetail(
//                                         id: item['sub_id'],
//                                         title: item['title'],
//                                         color: color,
//                                         desc: item['desc'])),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//       bottomNavigationBar: BottomNav(
//         currentIndex: 0,
//         onTap: (index) {
//           // Handle bottom navigation tap if needed
//         },
//       ),
//     );
//   }

//   Widget _buildStatisticCategory({
//     required IconData icon,
//     required String title,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       color: color, // Set the card color to the passed color
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Row(
//             children: [
//               Icon(icon,
//                   color: Colors.white, size: 25), // Changed icon color to white
//               const SizedBox(width: 15),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(Icons.chevron_right,
//                   color: Colors.white), // Changed icon color to white
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<List<dynamic>> fetchData(String url) async {
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body)['data'][1];
//         // Save data offline
//         await OfflineStorage.saveData(url, jsonResponse);
//         return jsonResponse;
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       // Load data from offline storage if API call fails
//       final offlineData = await OfflineStorage.loadData(url);
//       if (offlineData != null) {
//         return offlineData as List<dynamic>;
//       } else {
//         throw Exception('Failed to load data and no offline data available');
//       }
//     }
//   }
// }
