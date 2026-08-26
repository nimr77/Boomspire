import 'package:flutter/foundation.dart';

import '../models/game_status.dart';

/// Live, observable session state: health, gold, wave progress and outcome.
///
/// Extends [ChangeNotifier] so the presentation layer (HUD, overlays) can
/// simply `AnimatedBuilder`/`ListenableBuilder` on it.
abstract class GameStateRepository extends ChangeNotifier {
  int get health;
  int get gold;
  int get currentWave;
  int get totalWaves;
  GameStatus get status;

  void damagePlayer(int amount);
  bool spendGold(int amount);
  void addGold(int amount);
  void setWave(int waveNumber, {required int totalWaves});
  void setStatus(GameStatus status);
  void reset();
}
