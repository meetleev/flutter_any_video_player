import 'package:flutter/material.dart';

import 'page/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Any Video Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MaterialHomePage(title: 'Any Video Demo'),
    );
  }
}
