import 'package:flutter/material.dart';
import '../flavors.dart';
import '../presentation/screens/map/map_screen.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(F.title)),
      body: const MapScreen(),
    );
  }
}
