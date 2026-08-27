import 'package:flutter/foundation.dart';

import '../models/game_status.dart';

/// Live, observable session state: health, gold, wave progress and outcome.
///
/// Extends [ChangeNotifier] so the presentation layer (HUD, overlays) can
/// simply `AnimatedBuilder`/`ListenableBuilder` on it.
abstract class GameStateRepository extends ChangeNotifier {
  /// Second resource, earned by holding capturable resource nodes (see
  /// `ResourceNodeComponent`) - gold-only wave-defense scenes never touch
  /// this, it stays at zero.
  int get crystals;

  /// Live in-run score shown on the HUD and level-select header - waves
  /// cleared weighted heavily plus all gold ever earned. `GamePage` adds a
  /// separate victory bonus on top of this when recording final progress.
  int get currentScore => currentWave * 100 + goldEarned;
  int get currentWave;
  int get gold;
  int get goldEarned;

  int get health;

  /// How many enemies have been killed this run - drives the escalating
  /// bonus in [addKillGold].
  int get killCount;

  GameStatus get status;

  int get totalWaves;

  /// Awards crystals paid out by an owned resource node (see
  /// `ResourceNodeComponent`).
  void addCrystals(int amount);

  void addGold(int amount);

  /// Awards gold for a kill, boosted by an escalating streak bonus (+5%,
  /// +10%, +20%, +40%, +80%, then capped at +100% for every kill after) -
  /// see `GameConfig.killGoldBonusTiers` - plus [extraBonus] (e.g. from
  /// standing Gold Mines, see `BoomspireGame.goldMineKillGoldBonus`).
  /// Returns the actual amount added (base + bonuses) so callers can show
  /// it in floating text.
  int addKillGold(int baseAmount, {double extraBonus = 0});
  void damagePlayer(int amount);

  /// Resets to a fresh run. [startingGold] overrides
  /// `GameConfig.startingGold` when the active scene specifies its own
  /// economy (e.g. a skirmish scene's higher starting gold).
  void reset({int? startingGold});
  void setStatus(GameStatus status);
  void setWave(int waveNumber, {required int totalWaves});
  bool spendGold(int amount);
}
