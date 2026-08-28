// Proves the RTS free-scroll camera pans and clamps correctly - uses a fake
// terrain repository that reports a map far bigger than the fixed viewport,
// since every real scene today happens to be exactly viewport-sized (see
// GameWorld._panCamera, which is a no-op whenever the map already fits on
// screen).
import 'package:boomspire/core/combat/mobile_unit_repository_impl.dart';
import 'package:boomspire/core/pathfinding/grid.dart';
import 'package:boomspire/core/rendering/impl/procedural_unit_render_repository_impl.dart';
import 'package:boomspire/features/ai_director/impl/ai_director_repository_impl.dart';
import 'package:boomspire/features/audio/domain/models/sfx_type.dart';
import 'package:boomspire/features/audio/domain/repos/audio_repository.dart';
import 'package:boomspire/features/game_core/domain/models/game_scene.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/game_core/impl/game_state_repository_impl.dart';
import 'package:boomspire/features/game_core/presentation/boomspire_game.dart';
import 'package:boomspire/features/terrain/domain/models/terrain_map.dart';
import 'package:boomspire/features/terrain/domain/repos/terrain_repository.dart';
import 'package:boomspire/features/terrain/impl/terrain_repository_impl.dart';
import 'package:boomspire/features/towers/impl/building_repository_impl.dart';
import 'package:boomspire/features/towers/impl/tower_repository_impl.dart';
import 'package:boomspire/features/waves/impl/wave_repository_impl.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

const _viewport = 1280.0;
const _hugeArena = 3000.0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  test('camera stays put on a map that already fits the viewport', () async {
    final game = await _bootGame(
      GameScenes.all.first,
      _HugeTerrainRepository(enabled: false),
    );

    game.world.onKeyEvent(_keyDown(LogicalKeyboardKey.arrowRight), {
      LogicalKeyboardKey.arrowRight,
    });
    game.update(1);

    expect(game.world.cameraPosition, Vector2.zero());
  });

  test('arrow keys pan the camera on a map bigger than the viewport', () async {
    final game = await _bootGame(
      GameScenes.all.first,
      _HugeTerrainRepository(enabled: true),
    );

    game.world.onKeyEvent(_keyDown(LogicalKeyboardKey.arrowRight), {
      LogicalKeyboardKey.arrowRight,
    });
    game.update(0.1);

    expect(game.world.cameraPosition.x, greaterThan(0));
    expect(game.world.cameraPosition.y, 0);
  });

  test('panning clamps at the map edge', () async {
    final game = await _bootGame(
      GameScenes.all.first,
      _HugeTerrainRepository(enabled: true),
    );

    game.world.onKeyEvent(_keyDown(LogicalKeyboardKey.arrowRight), {
      LogicalKeyboardKey.arrowRight,
    });
    // Many seconds' worth of panning - would overshoot without clamping.
    for (var i = 0; i < 200; i++) {
      game.update(0.1);
    }

    expect(game.world.cameraPosition.x, _hugeArena - _viewport);
  });
}

KeyDownEvent _keyDown(LogicalKeyboardKey key) => KeyDownEvent(
  logicalKey: key,
  physicalKey: PhysicalKeyboardKey.arrowRight,
  timeStamp: Duration.zero,
);

Future<BoomspireGame> _bootGame(
  GameScene scene,
  TerrainRepository terrainRepository,
) async {
  final game = BoomspireGame(
    terrainRepository: terrainRepository,
    towerRepository: TowerRepositoryImpl(),
    buildingRepository: BuildingRepositoryImpl(),
    unitRepository: MobileUnitRepositoryImpl(),
    waveRepository: WaveRepositoryImpl(
      totalWaves: scene.waveCount,
      biome: scene.biome,
    ),
    audioRepository: _FakeAudioRepository(),
    gameState: GameStateRepositoryImpl(),
    aiDirector: AiDirectorRepositoryImpl(),
    unitRenderRepository: ProceduralUnitRenderRepositoryImpl(),
    scene: scene,
  );
  game.onGameResize(Vector2(_viewport, _viewport * 9 / 16));
  // ignore: invalid_use_of_internal_member
  await game.load();
  // ignore: invalid_use_of_internal_member
  game.mount();
  game.update(0);
  return game;
}

/// Wraps the real terrain generation but reports (and pads the grid to) a
/// much bigger arena when [enabled], simulating a future "huge map" scene.
class _HugeTerrainRepository implements TerrainRepository {
  final bool enabled;

  _HugeTerrainRepository({required this.enabled});

  @override
  TerrainMap loadTerrain({required GameScene scene}) {
    if (!enabled) return TerrainRepositoryImpl().loadTerrain(scene: scene);

    const cellSize = 40.0;
    final cols = (_hugeArena / cellSize).round();
    final rows = (_hugeArena / cellSize).round();
    return TerrainMap(
      arenaWidth: _hugeArena,
      arenaHeight: _hugeArena,
      grid: Grid(cols: cols, rows: rows, cellSize: cellSize),
      biome: scene.biome,
      obstacleKinds: List.generate(rows, (_) => List.filled(cols, null)),
      spawnPoints: const [PathPoint(0, 0)],
      basePoint: const PathPoint(0, 0),
    );
  }
}

/// No-op audio - the real impl needs real audio plugins that aren't
/// available under `flutter test`.
class _FakeAudioRepository implements AudioRepository {
  @override
  Future<void> preload() async {}

  @override
  void play(SfxType type, {double volume = 1.0}) {}
}
