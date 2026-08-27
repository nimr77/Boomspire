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

  /// Seconds between each Gold Mine passive payout tick (see
  /// `GoldMineComponent`).
  static const goldMineTickInterval = 5.0;

  /// Passive gold paid out per tick at upgrade tier 0 - rises by one more
  /// full base payout per upgrade tier (see `GoldMineComponent.payoutAmount`).
  static const goldMineBaseGoldPerTick = 5;

  /// Bonus added on top of every kill-gold reward per active Gold Mine at
  /// upgrade tier 0 (5%) - rises by one more full base bonus per upgrade
  /// tier (see `GoldMineComponent.killGoldBonus` and
  /// `BoomspireGame.goldMineKillGoldBonus`).
  static const goldMineBaseKillGoldBonus = 0.05;

  /// How close a vehicle must be to a resource node to contest/hold it
  /// (see `ResourceNodeComponent`).
  static const resourceNodeCaptureRadius = 48.0;

  /// Seconds an uncontested vehicle must hold a resource node before it
  /// flips to that vehicle's team.
  static const resourceNodeCaptureTime = 4.0;

  /// Seconds between each owned resource node's crystal payout.
  static const resourceNodePayoutInterval = 6.0;

  /// Crystals paid out per tick by an owned resource node.
  static const resourceNodeCrystalsPerTick = 10;

  /// Gold paid out per tick by a resource node owned by the AI opponent in
  /// a skirmish match - crystals are a player-only currency, so an
  /// AI-held node pays into `AiEconomy.gold` at this rate instead.
  static const aiResourceNodeGoldPerTick = 60;
}
