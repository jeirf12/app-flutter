import 'package:example_flutter/templates/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Download Videos",
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.teal,
        ),
        textTheme: const TextTheme(
          headline3: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            // color: Color(0XFF949494),
            color: Colors.teal,
          ),
        ),
      ),
      home: const Home(),
    );
  }
}
