import 'package:flutter/material.dart';
import 'package:sadadem/subject/homepage.dart';


class TablePage extends StatelessWidget {
  final String id;
  final String title;

  const TablePage({super.key, required this.id, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchData(
            'https://webapi.bps.go.id/v1/api/view/domain/3321/model/tablestatistic/id/$id/lang/ind/key/b73ea5437eb23fb8309858b840029da2/'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data yang tersedia'));
          } else {
            // Ambil data dari nested JSON
            final datas = snapshot.data!;
            
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStateColor.resolveWith(
                      (states) => Colors.blueGrey[50]!),
                  columns: const [
                    DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Variabel', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Satuan', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Tahun', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: datas.map<DataRow>((item) {
                    return DataRow(cells: [
                      DataCell(Text(item['var_id'].toString())),
                      DataCell(SizedBox(
                          width: 200,
                          child: Text(item['var_name'] ?? '-'))),
                      DataCell(Text(item['unit'] ?? '-')),
                      DataCell(Text(item['year'] ?? '-')),
                    ]);
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}