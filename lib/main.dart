import 'dart:io';
import 'package:example_flutter/services/download_manager.dart';
import 'package:example_flutter/templates/home.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestInitialPermissions();
  await downloadManager.loadTasks();
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
          headlineSmall: TextStyle(
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

Future<void> _requestInitialPermissions() async {
  if (Platform.isAndroid) {
    await [
      Permission.storage,
      Permission.requestInstallPackages,
    ].request();

    if(await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }
  } else if (Platform.isIOS) {
    await [
      Permission.photos,
      Permission.notification,
    ].request();
  }
}