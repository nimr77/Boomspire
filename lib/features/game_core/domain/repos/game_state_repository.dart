import 'package:flutter/foundation.dart';

import '../models/game_status.dart';

/// Live, observable session state: health, gold, wave progress and outcome.
///
/// Extends [ChangeNotifier] so the presentation layer (HUD, overlays) can
/// simply `AnimatedBuilder`/`ListenableBuilder` on it.
abstract class GameStateRepository extends ChangeNotifier {
  int get currentWave;
  int get gold;
  int get goldEarned;
  int get health;
  GameStatus get status;
  int get totalWaves;

  /// Live in-run score shown on the HUD and level-select header - waves
  /// cleared weighted heavily plus all gold ever earned. `GamePage` adds a
  /// separate victory bonus on top of this when recording final progress.
  int get currentScore => currentWave * 100 + goldEarned;

  void addGold(int amount);
  void damagePlayer(int amount);
  void reset();
  void setStatus(GameStatus status);
  void setWave(int waveNumber, {required int totalWaves});
  bool spendGold(int amount);
}
