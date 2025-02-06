import 'package:flutter/material.dart';
import 'package:sadadem/subject/homepage.dart';

class ListDetail extends StatelessWidget {
  final int id;
  final String title;

  const ListDetail({super.key, required this.id, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 100, 182),
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
            // Positioned.fill(
            // child: Image.asset(
            //   'assets/img/background.jpg', // Replace with your image path
            //   fit: BoxFit.cover,
            // ),
            // ),
          FutureBuilder<List<dynamic>>(
            future: fetchData('https://webapi.bps.go.id/v1/api/list/domain/3321/model/subjectcsa/subcat/$id/key/b73ea5437eb23fb8309858b840029da2/'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data available'));
              } else {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var item = snapshot.data![index];
                            return _buildStatisticCategory(
                              icon: Icons.folder_copy_sharp,
                              title: item['title'],
                              color: Colors.white,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCategory({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Card(
      color: const Color.fromARGB(255, 0, 100, 182),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
