import 'package:flutter/material.dart';

import '../circuit_defense_game.dart';
import 'end_screen.dart';

class VictoryOverlay extends StatelessWidget {
  const VictoryOverlay({super.key, required this.game});

  final CircuitDefenseGame game;

  @override
  Widget build(BuildContext context) {
    return EndScreen(
      title: 'DEFENSE HOLDS',
      subtitle: 'All ${game.waveRepository.totalWaves} waves repelled!',
      accentColor: Colors.greenAccent,
      onRestart: game.restart,
    );
  }
}
