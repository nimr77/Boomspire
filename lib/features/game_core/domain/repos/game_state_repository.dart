import 'package:flutter/foundation.dart';

import '../models/game_status.dart';

/// Live, observable session state: health, gold, wave progress and outcome.
///
/// Extends [ChangeNotifier] so the presentation layer (HUD, overlays) can
/// simply `AnimatedBuilder`/`ListenableBuilder` on it.
abstract class GameStateRepository extends ChangeNotifier {
  int get currentWave;
  int get gold;
  int get health;
  GameStatus get status;
  int get totalWaves;

  void addGold(int amount);
  void damagePlayer(int amount);
  void reset();
  void setStatus(GameStatus status);
  void setWave(int waveNumber, {required int totalWaves});
  bool spendGold(int amount);
}
