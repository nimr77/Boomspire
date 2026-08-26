import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../circuit_defense_game.dart';
import 'end_screen.dart';

class GameOverOverlay extends StatelessWidget {
  final CircuitDefenseGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return EndScreen(
      title: S.current.baseOverrunTitle,
      subtitle: S.current.baseOverrunSubtitle,
      accentColor: Colors.redAccent,
      onRestart: game.restart,
      onChangeMap: game.backToLevelSelect,
    );
  }
}
