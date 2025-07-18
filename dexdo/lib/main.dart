
import 'package:flutter/material.dart';
import 'package:dexdo/screens/home_screen.dart';

void main() {
  runApp(const DeXDo());
}

class DeXDo extends StatelessWidget {
  const DeXDo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeXDo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}
