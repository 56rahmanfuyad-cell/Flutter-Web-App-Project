
import 'package:flutter/material.dart';
import 'package:my_project/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Skill Share',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
