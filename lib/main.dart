import 'package:flutter/material.dart';
import 'subject/homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dalem',
      theme: ThemeData(
        
        primaryColor: Colors.white,
      ),
      home: Homepage(),
    );
  }
}
