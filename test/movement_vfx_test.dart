// Proves that the "while moving" vehicle VFX (engine smoke, heavy-vehicle
// tread marks, light-vehicle dust puffs) documented in
// MobileUnitComponent's per-frame update actually spawn into the world
// during real gameplay, not just in theory.
import 'package:boomspire/core/combat/mobile_unit_blueprint.dart';
import 'package:boomspire/core/combat/mobile_unit_repository_impl.dart';
import 'package:boomspire/core/combat/team.dart';
import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/core/combat/unit_objective.dart';
import 'package:boomspire/core/rendering/impl/procedural_unit_render_repository_impl.dart';
import 'package:boomspire/features/ai_director/impl/ai_director_repository_impl.dart';
import 'package:boomspire/features/audio/domain/models/ambient_sound_type.dart';
import 'package:boomspire/features/audio/domain/models/sfx_type.dart';
import 'package:boomspire/features/audio/domain/repos/audio_repository.dart';
import 'package:boomspire/features/combat/presentation/dust_puff_component.dart';
import 'package:boomspire/features/combat/presentation/mobile_unit_component.dart';
import 'package:boomspire/features/combat/presentation/smoke_trail_component.dart';
import 'package:boomspire/features/combat/presentation/track_mark_component.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/game_core/impl/game_state_repository_impl.dart';
import 'package:boomspire/features/game_core/presentation/boomspire_game.dart';
import 'package:boomspire/features/terrain/impl/terrain_repository_impl.dart';
import 'package:boomspire/features/towers/impl/building_repository_impl.dart';
import 'package:boomspire/features/towers/impl/tower_repository_impl.dart';
import 'package:boomspire/features/waves/impl/wave_repository_impl.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  test(
    'a moving heavy vehicle leaves engine smoke and tread marks, no dust',
    () async {
      final game = await _bootGame();
      final tank = await _spawnMoving(game, UnitKind.tank);

      for (var i = 0; i < 40; i++) {
        game.update(0.1);
      }

      expect(game.world.children.whereType<SmokeTrailComponent>(), isNotEmpty);
      expect(game.world.children.whereType<TrackMarkComponent>(), isNotEmpty);
      expect(game.world.children.whereType<DustPuffComponent>(), isEmpty);
      tank.removeFromParent();
    },
  );

  test('a moving light vehicle leaves dust puffs, no tread marks', () async {
    final game = await _bootGame();
    final buggy = await _spawnMoving(game, UnitKind.lightVehicle);

    for (var i = 0; i < 40; i++) {
      game.update(0.1);
    }

    expect(game.world.children.whereType<DustPuffComponent>(), isNotEmpty);
    expect(game.world.children.whereType<TrackMarkComponent>(), isEmpty);
    buggy.removeFromParent();
  });
}

Future<BoomspireGame> _bootGame() async {
  final scene = GameScenes.all.first;
  final game = BoomspireGame(
    terrainRepository: TerrainRepositoryImpl(),
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
  game.onGameResize(Vector2(1280, 720));
  // ignore: invalid_use_of_internal_member
  await game.load();
  // ignore: invalid_use_of_internal_member
  game.mount();
  game.update(0);
  return game;
}

/// Spawns an invader of [kind] with [UnitObjective.rushBase] (always has a
/// movement goal: the player base) and no attack, so it just walks/drives
/// every tick instead of possibly stopping to engage something in range.
/// Awaits one mount flush - `spawnUnit` fires the async `onLoad` (which
/// awaits the render repository) without waiting for it, so without this
/// the unit would never actually finish mounting and its per-frame VFX
/// spawn logic (in `update()`) would never run.
Future<MobileUnitComponent> _spawnMoving(
  BoomspireGame game,
  UnitKind kind,
) async {
  final blueprint = MobileUnitBlueprint(
    kind: kind,
    name: 'Test $kind',
    maxHealth: 500,
    speed: 80,
    bounty: 0,
    size: 50,
    isVehicle: true,
  );
  final unit = MobileUnitComponent(
    blueprint: blueprint,
    team: Team.invaders,
    objective: UnitObjective.rushBase,
  );
  game.world.spawnUnit(unit);
  await Future<void>.delayed(Duration.zero);
  game.update(0);
  return unit;
}

class _FakeAudioRepository implements AudioRepository {
  @override
  void play(SfxType type, {double volume = 1.0}) {}

  @override
  Future<void> preload() async {}

  @override
  void setAmbientVolume(AmbientSoundType type, double volume) {}
}
