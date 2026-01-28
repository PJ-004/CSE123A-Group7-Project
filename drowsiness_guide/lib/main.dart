import 'package:flutter/material.dart';
// import 'package:google_maps/google_maps.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Now without Linux, Windows, or Mac OS X support!'),
        ),
      ),
    );
  }
}
