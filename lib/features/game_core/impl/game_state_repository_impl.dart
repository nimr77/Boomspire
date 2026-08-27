import '../domain/models/game_config.dart';
import '../domain/models/game_status.dart';
import '../domain/repos/game_state_repository.dart';

class GameStateRepositoryImpl extends GameStateRepository {
  int _health = GameConfig.startingHealth;
  int _gold = GameConfig.startingGold;
  int _goldEarned = 0;
  int _crystals = 0;
  int _currentWave = 1;
  int _totalWaves = 1;
  int _killCount = 0;
  GameStatus _status = GameStatus.playing;

  @override
  int get crystals => _crystals;
  @override
  int get currentWave => _currentWave;
  @override
  int get gold => _gold;
  @override
  int get goldEarned => _goldEarned;
  @override
  int get health => _health;
  @override
  int get killCount => _killCount;
  @override
  GameStatus get status => _status;
  @override
  int get totalWaves => _totalWaves;

  @override
  void addCrystals(int amount) {
    _crystals += amount;
    notifyListeners();
  }

  @override
  void addGold(int amount) {
    _gold += amount;
    _goldEarned += amount;
    notifyListeners();
  }

  @override
  int addKillGold(int baseAmount, {double extraBonus = 0}) {
    final tiers = GameConfig.killGoldBonusTiers;
    final bonus = tiers[_killCount.clamp(0, tiers.length - 1)];
    _killCount++;
    final amount = (baseAmount * (1 + bonus + extraBonus)).round();
    addGold(amount);
    return amount;
  }

  @override
  void damagePlayer(int amount) {
    if (_status != GameStatus.playing) return;
    _health = (_health - amount).clamp(0, GameConfig.startingHealth * 10);
    if (_health <= 0) {
      _health = 0;
      _status = GameStatus.gameOver;
    }
    notifyListeners();
  }

  @override
  void reset({int? startingGold}) {
    _health = GameConfig.startingHealth;
    _gold = startingGold ?? GameConfig.startingGold;
    _goldEarned = 0;
    _crystals = 0;
    _currentWave = 1;
    _killCount = 0;
    _status = GameStatus.playing;
    notifyListeners();
  }

  @override
  void setStatus(GameStatus status) {
    if (_status == GameStatus.gameOver && status != GameStatus.gameOver) {
      return;
    }
    _status = status;
    notifyListeners();
  }

  @override
  void setWave(int waveNumber, {required int totalWaves}) {
    _currentWave = waveNumber;
    _totalWaves = totalWaves;
    notifyListeners();
  }

  @override
  bool spendGold(int amount) {
    if (_gold < amount) return false;
    _gold -= amount;
    notifyListeners();
    return true;
  }
}
