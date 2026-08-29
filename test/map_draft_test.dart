// Proves the map editor's data model (JSON round-trip, weather timeline
// interpolation), its on-device storage, and the draft-to-preview terrain
// rasterizer (painted cells + freehand river/lake paths -> obstacle grid).
import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/core/storage/app_database.dart';
import 'package:boomspire/features/map_editor/domain/models/editor_point.dart';
import 'package:boomspire/features/map_editor/domain/models/environment_settings.dart';
import 'package:boomspire/features/map_editor/domain/models/map_draft.dart';
import 'package:boomspire/features/map_editor/domain/models/painted_cell.dart';
import 'package:boomspire/features/map_editor/domain/models/tree_cell.dart';
import 'package:boomspire/features/map_editor/domain/models/water_path.dart';
import 'package:boomspire/features/map_editor/domain/models/weather_keyframe.dart';
import 'package:boomspire/features/map_editor/impl/draft_wave_repository.dart';
import 'package:boomspire/features/map_editor/impl/editor_terrain_generator.dart';
import 'package:boomspire/features/map_editor/impl/local_map_draft_repository_impl.dart';
import 'package:boomspire/features/terrain/domain/models/biome.dart';
import 'package:boomspire/features/terrain/domain/models/obstacle_kind.dart';
import 'package:boomspire/features/waves/domain/models/wave_loadout.dart';
import 'package:boomspire/features/waves/impl/wave_loadout_generator.dart';
import 'package:boomspire/features/waves/impl/wave_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tostore/tostore.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapDraft JSON round-trip', () {
    test('round-trips every field through JSON', () {
      const draft = MapDraft(
        id: 'draft-1',
        name: 'My Map',
        arenaWidth: 2000,
        arenaHeight: 1500,
        paintedCells: [
          PaintedCell(col: 2, row: 3, kind: ObstacleKind.mountain),
        ],
        waterPaths: [
          WaterPath(
            kind: WaterFeatureKind.river,
            points: [EditorPoint(x: 0, y: 0), EditorPoint(x: 100, y: 100)],
            width: 60,
          ),
        ],
        environment: EnvironmentSettings(
          dynamicWeather: false,
          sunAngle: 0.2,
          timeline: [WeatherKeyframe(atProgress: 0, rainIntensity: 0.5)],
        ),
        waveCount: 12,
        waveLoadouts: [
          WaveLoadout(waveNumber: 1, unitCounts: {'soldier': 5, 'tank': 1}),
        ],
      );

      final restored = MapDraft.fromJson(draft.toJson());

      expect(restored, draft);
    });
  });

  group('WaveLoadout', () {
    test('countOf/withCount read and write per-kind counts', () {
      const loadout = WaveLoadout(waveNumber: 1);

      final updated = loadout.withCount(UnitKind.tank, 3);

      expect(updated.countOf(UnitKind.tank), 3);
      expect(updated.countOf(UnitKind.soldier), 0);
      expect(updated.totalUnits, 3);
    });

    test('withCount(0) removes the entry instead of storing a zero', () {
      const loadout = WaveLoadout(waveNumber: 1, unitCounts: {'tank': 2});

      final updated = loadout.withCount(UnitKind.tank, 0);

      expect(updated.unitCounts, isEmpty);
    });
  });

  group('WaveLoadoutGenerator', () {
    test('randomize produces one loadout per wave number, never empty', () {
      final loadouts = WaveLoadoutGenerator.randomize(20);

      expect(loadouts.length, 20);
      for (final (index, loadout) in loadouts.indexed) {
        expect(loadout.waveNumber, index + 1);
        expect(loadout.totalUnits, greaterThan(0));
      }
    });
  });

  group('DraftWaveRepository', () {
    test('uses the authored loadout for a customized wave', () {
      final repo = DraftWaveRepository(
        loadouts: const [
          WaveLoadout(waveNumber: 2, unitCounts: {'tank': 4}),
        ],
        totalWaves: 5,
        fallback: WaveRepositoryImpl(totalWaves: 5, biome: Biome.grassPlains),
      );

      final def = repo.waveDefinition(2);

      expect(def.spawns, hasLength(1));
      expect(def.spawns.single.type, UnitKind.tank);
      expect(def.spawns.single.count, 4);
    });

    test('falls back to the procedural wave for an uncustomized wave', () {
      final fallback = WaveRepositoryImpl(
        totalWaves: 5,
        biome: Biome.grassPlains,
      );
      final repo = DraftWaveRepository(
        loadouts: const [],
        totalWaves: 5,
        fallback: fallback,
      );

      final def = repo.waveDefinition(3);
      final expected = fallback.waveDefinition(3);

      expect(def.waveNumber, expected.waveNumber);
      expect(def.totalEnemies, expected.totalEnemies);
      expect(def.spawns.length, expected.spawns.length);
    });
  });

  group('EnvironmentSettings.sample', () {
    test('interpolates between two keyframes when dynamic', () {
      const settings = EnvironmentSettings(
        timeline: [
          WeatherKeyframe(atProgress: 0, rainIntensity: 0),
          WeatherKeyframe(atProgress: 1, rainIntensity: 1),
        ],
      );

      expect(settings.sample(0.5).rainIntensity, closeTo(0.5, 0.0001));
    });

    test('stays on the first keyframe when not dynamic', () {
      const settings = EnvironmentSettings(
        dynamicWeather: false,
        timeline: [
          WeatherKeyframe(atProgress: 0, rainIntensity: 0.2),
          WeatherKeyframe(atProgress: 1, rainIntensity: 1),
        ],
      );

      expect(settings.sample(0.9).rainIntensity, 0.2);
    });

    test('windType is not lerped - it steps from the earlier keyframe to '
        'the later one at the halfway point instead', () {
      const settings = EnvironmentSettings(
        timeline: [
          WeatherKeyframe(atProgress: 0),
          WeatherKeyframe(atProgress: 1, windType: WindType.ash),
        ],
      );

      expect(settings.sample(0.2).windType, WindType.automatic);
      expect(settings.sample(0.8).windType, WindType.ash);
    });
  });

  group('LocalMapDraftRepositoryImpl', () {
    setUp(() => AppDatabase.useForTest(ToStore.memory));
    tearDown(AppDatabase.reset);

    test('saves, lists, loads and deletes drafts', () async {
      final repo = LocalMapDraftRepositoryImpl();
      const draft = MapDraft(id: 'a', name: 'A');

      await repo.saveDraft(draft);
      expect((await repo.listDrafts()).map((d) => d.id), ['a']);
      expect((await repo.loadDraft('a'))?.name, 'A');

      await repo.saveDraft(draft.copyWith(name: 'A renamed'));
      expect((await repo.loadDraft('a'))?.name, 'A renamed');

      await repo.deleteDraft('a');
      expect(await repo.listDrafts(), isEmpty);
    });
  });

  group('EditorTerrainGenerator', () {
    test('rasterizes painted cells as obstacles', () async {
      const draft = MapDraft(
        id: 'x',
        name: 'x',
        arenaWidth: 400,
        arenaHeight: 400,
        paintedCells: [PaintedCell(col: 1, row: 1, kind: ObstacleKind.dune)],
      );

      final preview = await EditorTerrainGenerator().generate(draft);

      expect(preview.obstacleKinds[1][1], ObstacleKind.dune);
      expect(preview.grid.isBlocked(1, 1), isTrue);
      expect(preview.grid.isBlocked(0, 0), isFalse);
    });

    test('rasterizes a river path as a channel of river cells', () async {
      const draft = MapDraft(
        id: 'x',
        name: 'x',
        arenaWidth: 400,
        arenaHeight: 40,
        waterPaths: [
          WaterPath(
            kind: WaterFeatureKind.river,
            points: [EditorPoint(x: 0, y: 20), EditorPoint(x: 400, y: 20)],
            width: 30,
          ),
        ],
      );

      final preview = await EditorTerrainGenerator().generate(draft);

      // The river runs straight through row 0 (cell centered at y=20).
      expect(preview.obstacleKinds[0][5], ObstacleKind.river);
    });

    test('rasterizes a lake path as filled lake cells', () async {
      const draft = MapDraft(
        id: 'x',
        name: 'x',
        arenaWidth: 400,
        arenaHeight: 400,
        waterPaths: [
          WaterPath(
            kind: WaterFeatureKind.lake,
            points: [
              EditorPoint(x: 40, y: 40),
              EditorPoint(x: 360, y: 40),
              EditorPoint(x: 360, y: 360),
              EditorPoint(x: 40, y: 360),
            ],
          ),
        ],
      );

      final preview = await EditorTerrainGenerator().generate(draft);

      // Center of the lake polygon should be filled...
      expect(preview.obstacleKinds[5][5], ObstacleKind.lake);
      // ...but far outside the polygon should stay open ground.
      expect(preview.obstacleKinds[0][0], isNull);
    });

    test('rasterizes a lava path as a channel of lava cells, blocked like '
        'any other obstacle', () async {
      const draft = MapDraft(
        id: 'x',
        name: 'x',
        arenaWidth: 400,
        arenaHeight: 40,
        waterPaths: [
          WaterPath(
            kind: WaterFeatureKind.lava,
            points: [EditorPoint(x: 0, y: 20), EditorPoint(x: 400, y: 20)],
            width: 30,
          ),
        ],
      );

      final preview = await EditorTerrainGenerator().generate(draft);

      expect(preview.obstacleKinds[0][5], ObstacleKind.lava);
      expect(preview.grid.isBlocked(5, 0), isTrue);
    });

    test('rasterizes a volcanic lake path as filled volcanicLake cells, '
        'blocked like any other obstacle', () async {
      const draft = MapDraft(
        id: 'x',
        name: 'x',
        arenaWidth: 400,
        arenaHeight: 400,
        waterPaths: [
          WaterPath(
            kind: WaterFeatureKind.volcanicLake,
            points: [
              EditorPoint(x: 40, y: 40),
              EditorPoint(x: 360, y: 40),
              EditorPoint(x: 360, y: 360),
              EditorPoint(x: 40, y: 360),
            ],
          ),
        ],
      );

      final preview = await EditorTerrainGenerator().generate(draft);

      expect(preview.obstacleKinds[5][5], ObstacleKind.volcanicLake);
      expect(preview.grid.isBlocked(5, 5), isTrue);
      expect(preview.obstacleKinds[0][0], isNull);
    });

    test("a tree's brush-type variant only reaches the terrain's variants grid "
        'when EnvironmentAdaptation is manual', () async {
      const automaticDraft = MapDraft(
        id: 'x',
        name: 'x',
        arenaWidth: 400,
        arenaHeight: 400,
        biome: Biome.desertDunes,
        treeCells: [TreeCell(col: 2, row: 2, variant: Biome.snowTundra)],
      );

      final automaticPreview = await EditorTerrainGenerator().generate(
        automaticDraft,
      );
      expect(automaticPreview.variants[2][2], isNull);

      final manualDraft = automaticDraft.copyWith(
        environment: const EnvironmentSettings(
          adaptation: EnvironmentAdaptation.manual,
        ),
      );
      final manualPreview = await EditorTerrainGenerator().generate(
        manualDraft,
      );
      expect(manualPreview.variants[2][2], Biome.snowTundra);
    });
  });
}
