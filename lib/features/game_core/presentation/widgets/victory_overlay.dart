import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../domain/models/game_scene.dart';
import '../boomspire_game.dart';
import 'end_screen.dart';

class VictoryOverlay extends StatelessWidget {
  final BoomspireGame game;

  const VictoryOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final subtitle = game.scene.mode == GameMode.skirmish
        ? S.current.skirmishVictorySubtitle
        : S.current.defenseHoldsSubtitle(game.waveRepository.totalWaves);
    return EndScreen(
      title: S.current.defenseHoldsTitle,
      subtitle: subtitle,
      accentColor: Colors.greenAccent,
      onRestart: game.restart,
      onChangeMap: game.backToLevelSelect,
    );
  }
}
