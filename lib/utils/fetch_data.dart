import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchData {
  static Future<Map<String, dynamic>> getData(String url) async {
    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}