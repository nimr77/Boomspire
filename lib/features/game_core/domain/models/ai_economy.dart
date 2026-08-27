/// The AI opponent's own gold wallet + base HP for a [GameMode.skirmish]
/// match - deliberately separate from [GameStateRepository], which is (and
/// stays) the single human player's wallet. A full multi-wallet redesign of
/// [GameStateRepository] would touch far more of the codebase than a
/// skirmish opponent needs; this is a small, ephemeral, per-match mirror of
/// just the two numbers [AiSkirmishControllerComponent]/[AiHomeBaseComponent]
/// actually need.
class AiEconomy {
  int gold;
  int health;
  final int maxHealth;

  AiEconomy({this.gold = 150, this.health = 20, this.maxHealth = 20});

  bool get isDefeated => health <= 0;

  void addGold(int amount) => gold += amount;

  void damageBase(int amount) {
    if (isDefeated) return;
    health = (health - amount).clamp(0, maxHealth);
  }

  bool spendGold(int amount) {
    if (gold < amount) return false;
    gold -= amount;
    return true;
  }
}
