import 'package:flutter/material.dart';
import 'package:health_care/login/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome to Flutter',
      home: SafeArea(child: LoginPage()),
    );
  }
}
