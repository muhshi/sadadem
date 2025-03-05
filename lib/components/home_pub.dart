import 'package:flutter/material.dart';
import 'package:Dalem/publikasi/detail_publikasi.dart';

class HomePublication extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final Function() onSeeAll;

  const HomePublication(
      {super.key,
      required this.title,
      required this.data,
      required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
        color: Colors.grey.withAlpha(128),
        spreadRadius: 2,
        blurRadius: 10,
        offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            onPressed: onSeeAll,
            icon: Icon(Icons.arrow_forward, color: Colors.blue.shade900),
            label: Text(
              'Lihat Semua',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              var item = data[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          item['cover'],
                          width: double.infinity,
                          height: 400,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        item['rl_date'] ?? 'No Date',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text(
                        item['title'],
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPublikasi(publication: item),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
