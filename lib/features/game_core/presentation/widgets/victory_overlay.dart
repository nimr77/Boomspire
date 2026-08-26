import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../boomspire_game.dart';
import 'end_screen.dart';

class VictoryOverlay extends StatelessWidget {
  final BoomspireGame game;

  const VictoryOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return EndScreen(
      title: S.current.defenseHoldsTitle,
      subtitle: S.current.defenseHoldsSubtitle(game.waveRepository.totalWaves),
      accentColor: Colors.greenAccent,
      onRestart: game.restart,
      onChangeMap: game.backToLevelSelect,
    );
  }
}
