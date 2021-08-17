import 'package:flutter/material.dart';
import './PlantDisease.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Plant Disease Detector',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.amberAccent,
      ),
      home: PlantDisease(),
    );
  }
}
