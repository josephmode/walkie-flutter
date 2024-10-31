import 'package:flutter/material.dart';
//import 'Views/index.dart';
import 'Views/prueba_recorder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walkie Talkie',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Walkie Talkie'),
        ),
        body: const PruebaRecorder(),
      ),
    );
  }
}
