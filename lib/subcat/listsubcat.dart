import 'package:flutter/material.dart';
import 'package:Dalem/cate/catdetail.dart';
import 'package:Dalem/subject/homepage.dart';

class ListDetail extends StatelessWidget {
  final int id;
  final String title;

  const ListDetail({super.key, required this.id, required this.title});

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
      body: FutureBuilder<List<dynamic>>(
        future: fetchData(
            'https://webapi.bps.go.id/v1/api/list/domain/3321/model/subjectcsa/subcat/$id/perpage/20/key/b73ea5437eb23fb8309858b840029da2/'),
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
                          icon: Icons.folder_copy_outlined,
                          title: item['title'],
                          color: Colors.blue.shade900, // Changed color to blue
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Catdetail(
                                      id: item['sub_id'],
                                      title: item['title'],
                                      desc: item['desc'])),
                                     
                            );
                            print("Ini mau print id nya  ");
                          print(item['sub_id']);
                          },
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
    );
  }

  Widget _buildStatisticCategory({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: color, // Set the card color to the passed color
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 30), // Changed icon color to white
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
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white), // Changed icon color to white
            ],
          ),
        ),
      ),
    );
  }
}
