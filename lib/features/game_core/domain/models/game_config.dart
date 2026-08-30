/// Global tuning constants for a new game session.
class GameConfig {
  static const startingHealth = 20;
  static const startingGold = 150;

  /// Default starting gold for a [GameMode.skirmish] match (both the
  /// player and the AI opponent) - a real base-building economy war needs
  /// far more up-front capital than the drip-fed wave-defense economy.
  /// Overridable per-scene/per-draft via `GameScene.startingGold`.
  static const startingSkirmishGold = 3000;
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

  /// Grid cells an attacker must be within to detect (and therefore
  /// target) a stealth unit (`MobileUnitBlueprint.isStealth`), e.g. the
  /// Stealth Bomber - see `isTargetDetectable`.
  static const stealthDetectionRangeCells = 4.0;

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

  /// How often (seconds) `WeatherFocusState` locks in a brand new random
  /// blend of the scene's weather keyframes, uniformly between this and
  /// [weatherFocusMaxShiftSeconds].
  static const weatherFocusMinShiftSeconds = 60.0;

  /// Upper bound (seconds) on how long one blend holds before the next
  /// random reroll - 5 minutes, per design ("changes on a random timing,
  /// max 5 min").
  static const weatherFocusMaxShiftSeconds = 300.0;

  /// How long (seconds) `WeatherFocusState` takes to ease from one blend
  /// to the next once a reroll fires, uniformly between this and
  /// [weatherFocusTransitionMaxSeconds] - never instant, so the look/sound
  /// drifts naturally instead of jumping.
  static const weatherFocusTransitionMinSeconds = 15.0;
  static const weatherFocusTransitionMaxSeconds = 45.0;

  /// How much (0..1) sustained weapon fire ducks ambient weather sound -
  /// kept below 1 so a firefight quiets the ambience without silencing it
  /// (see `BoomspireGame.combatIntensity`/`AmbientWeatherAudioComponent`).
  static const combatAmbientDuckStrength = 0.75;

  /// How much each shot (`BoomspireGame.shakeCamera` call) bumps
  /// `BoomspireGame.combatIntensity`.
  static const combatIntensityPerShot = 0.15;

  /// How fast (per second) `BoomspireGame.combatIntensity` decays back
  /// toward 0 once shooting stops.
  static const combatIntensityDecayPerSecond = 0.4;

  /// Ceiling ambient volume (0..1) for the wind/rain ambience loops at
  /// full keyframe intensity (`windStrength`/`rainIntensity` == 1), before
  /// combat ducking - kept below 1 so ambience always sits under SFX.
  static const ambientWindMaxVolume = 0.45;
  static const ambientRainMaxVolume = 0.55;
}
