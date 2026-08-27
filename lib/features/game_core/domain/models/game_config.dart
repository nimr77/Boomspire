/// Global tuning constants for a new game session.
class GameConfig {
  static const startingHealth = 20;
  static const startingGold = 150;
  static const arenaWidth = 1280.0;
  static const arenaHeight = 720.0;

  /// Per-kill gold bonus, indexed by kill number this run (0 = first kill) -
  /// doubles each kill (5%, 10%, 20%, 40%, 80%) then caps at +100% (see
  /// `GameStateRepository.addKillGold`).
  static const killGoldBonusTiers = [0.05, 0.10, 0.20, 0.40, 0.80, 1.00];

  /// Added per current wave to tower upgrade cost multiplier - upgrades get
  /// steadily pricier as a run goes on (see `TowerComponent.upgradeCost`).
  static const upgradeCostWaveScaling = 0.03;

  /// Cooldown after mustering an Ally Soldier from the Training Center
  /// before another can be queued (see `TrainingCenterComponent.produceSoldier`).
  static const trainingCenterProductionCooldown = 8.0;

  /// Cooldown after rolling out an Ally vehicle/aircraft from the War
  /// Factory before another can be queued - longer than the Training
  /// Center's since these units hit much harder.
  static const warFactoryProductionCooldown = 12.0;

  /// Minimum `GameStateRepository.currentScore` needed to unlock the
  /// Training Center / War Factory support buildings in the build menu.
  static const trainingCenterUnlockScore = 250;
  static const warFactoryUnlockScore = 500;
}
