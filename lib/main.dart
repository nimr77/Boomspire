import 'package:flutter/material.dart';

import 'features/level_select/presentation/level_select_page.dart';

void main() {
  runApp(const CircuitDefenseApp());
}

class CircuitDefenseApp extends StatelessWidget {
  const CircuitDefenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circuit Defense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const LevelSelectPage(),
    );
  }
}
