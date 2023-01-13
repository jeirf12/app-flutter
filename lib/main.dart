import 'package:example_flutter/templates/home.dart';
import 'package:flutter/material.dart';
//TODO --> Implement connection with api youtube for list view videos

String title = "Download Videos";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, title});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          headline1: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Color(0XDD7C817D),
          ),
          headline2: TextStyle(
            fontSize: 44.0,
            fontWeight: FontWeight.w700,
            color: Color(0XFFFFCC00),
          ),
          headline3: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0XFF949494),
          ),
        ),
      ),
      home: const Home(),
    );
  }
}
