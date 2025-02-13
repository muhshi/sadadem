import 'package:flutter/material.dart';
import 'package:Dalem/subject/homepage.dart';
import 'package:Dalem/table/table.dart' as sadademTable;

import 'dart:convert';
class Catdetail extends StatelessWidget {
  final String title;
  final int id;
  final String desc;
  const Catdetail(
      {super.key, this.id = 0, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 43, 106, 1),
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 25, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.blue.shade900,
              padding: const EdgeInsets.all(10.0),
              child: Text(
                desc,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            FutureBuilder<List<dynamic>>(
              future: fetchData(
                  'https://webapi.bps.go.id/v1/api/list/domain/3321/model/tablestatistic/subject/$id/page/1/perpage/200/key/b73ea5437eb23fb8309858b840029da2/'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(120.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/img/server.png',
                            width: 200,
                            height: 200,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'DATA BELUM TERSEDIA',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                } else {
                  
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var item = snapshot.data![index];
                            return _buildStatisticCategory(
                              icon: Icons.bar_chart_outlined,
                              title: item['title'], 
                              lastUpdate: 'Terakhir Update: '+(item['last_update']??'-'),
                              color: Colors.blue.shade900,
                              onTap: () {
                                var decodedId = utf8.decode(base64.decode(item['id'].toString()));
                                var arrayId = decodedId.split('#');
                                var id = arrayId[0];
                                Navigator.push(
                                  context,
                                    MaterialPageRoute(
                                    builder: (context) =>
                                      sadademTable.DataTableScreen(
                                      id: id,
                                      title: item['title'],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticCategory({
    required IconData icon,
    required String title,
    required String lastUpdate,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.blue.shade900, // Set the background color of the Card to blue
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(icon,
                  color: Colors.white, size: 30), // Set the icon color to white
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text( lastUpdate,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white), // Set the chevron icon color to white
            ],
          ),
        ),
      ),
    );
  }
}
