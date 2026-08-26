import 'package:flutter/material.dart';

import '../circuit_defense_game.dart';
import 'end_screen.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final CircuitDefenseGame game;

  @override
  Widget build(BuildContext context) {
    return EndScreen(
      title: 'BASE OVERRUN',
      subtitle: 'The circuit has been breached.',
      accentColor: Colors.redAccent,
      onRestart: game.restart,
    );
  }
}
