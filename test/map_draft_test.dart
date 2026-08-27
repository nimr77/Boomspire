// Proves the map editor's data model (JSON round-trip, weather timeline
// interpolation), its on-device storage, and the draft-to-preview terrain
// rasterizer (painted cells + freehand river/lake paths -> obstacle grid).
import 'package:boomspire/features/map_editor/domain/models/environment_settings.dart';
import 'package:boomspire/features/map_editor/domain/models/map_draft.dart';
import 'package:boomspire/features/map_editor/domain/models/painted_cell.dart';
import 'package:boomspire/features/map_editor/domain/models/editor_point.dart';
import 'package:boomspire/features/map_editor/domain/models/water_path.dart';
import 'package:boomspire/features/map_editor/domain/models/weather_keyframe.dart';
import 'package:boomspire/features/map_editor/impl/editor_terrain_generator.dart';
import 'package:boomspire/features/map_editor/impl/local_map_draft_repository_impl.dart';
import 'package:boomspire/features/terrain/domain/models/obstacle_kind.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      );

      final restored = MapDraft.fromJson(draft.toJson());

      expect(restored, draft);
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
  });

  group('LocalMapDraftRepositoryImpl', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

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

    test('rasterizes a lake path as filled river cells', () async {
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
      expect(preview.obstacleKinds[5][5], ObstacleKind.river);
      // ...but far outside the polygon should stay open ground.
      expect(preview.obstacleKinds[0][0], isNull);
    });
  });
}
