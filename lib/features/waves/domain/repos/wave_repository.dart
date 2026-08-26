import '../models/wave_definition.dart';

/// Catalog of all rounds the game will run before ending.
abstract class WaveRepository {
  int get totalWaves;
  WaveDefinition waveDefinition(int waveNumber);
}
