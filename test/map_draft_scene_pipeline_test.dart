// Regression coverage proving a fully-configured MapDraft's config survives
// the *entire* real test-play pipeline (MapEditorPersistenceState.preparePlay
// -> GameScene / TerrainRepository / WaveRepository) with every field intact,
// and that the exported/re-imported JSON for both the draft and the
// resulting GameScene round-trips losslessly. This is what actually catches
// a config knob (like the editor's Environment/weather timeline once was)
// being editable in the UI but silently dropped before it ever reaches a
// real, playable scene.
import 'dart:convert';
import 'dart:ui';

import 'package:boomspire/core/combat/unit_kind.dart';
import 'package:boomspire/features/game_core/domain/models/game_scene.dart';
import 'package:boomspire/features/map_editor/domain/models/map_draft.dart';
import 'package:boomspire/features/map_editor/domain/models/weather_keyframe.dart';
import 'package:boomspire/features/map_editor/domain/repos/map_draft_repository.dart';
import 'package:boomspire/features/map_editor/presentation/state/map_editor_draft_state.dart';
import 'package:boomspire/features/map_editor/presentation/state/map_editor_persistence_state.dart';
import 'package:boomspire/features/terrain/domain/models/biome.dart';
import 'package:boomspire/generated/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  test('every field an author can set in the editor reaches the real play pipeline', () async {
    final draftState = MapEditorDraftState(
      const MapDraft(id: 'pipeline-test', name: 'Pipeline Test'),
    );
    addTearDown(draftState.dispose);
    await draftState.initialize();

    // Map/biome config.
    draftState.setBiome(Biome.mountainForest);
    draftState.applyArenaSize('1600', '800');
    draftState.applyStartingGold('4200');
    draftState.applyWaveCount('6');

    final canvasSize = Size(
      draftState.draft.value.arenaWidth,
      draftState.draft.value.arenaHeight,
    );

    // A hand-painted obstacle, away from the default spawn/base line so it
    // survives the terrain repository's reachability guarantee.
    draftState.setTool(EditorTool.mountain);
    draftState.handlePanStart(const Offset(400, 40), canvasSize);
    draftState.handlePanEnd();

    // A brush-type override (an icy mountain painted on this otherwise
    // forest map) so the variant survives all the way to the real terrain.
    draftState.setVariant(Biome.frozenPeaks);
    draftState.handlePanStart(const Offset(440, 40), canvasSize);
    draftState.handlePanEnd();
    draftState.setVariant(null);

    // A custom home site on the west side (the default, unset base sits
    // on the east edge) so we can prove it - not the default - was used.
    draftState.setTool(EditorTool.homeSite);
    draftState.handlePanStart(const Offset(60, 60), canvasSize);

    // A hand-placed tree, independent of the biome's automatic scatter -
    // authorable on any biome via the Tree tool.
    draftState.setTool(EditorTool.tree);
    draftState.handlePanStart(const Offset(800, 400), canvasSize);
    draftState.handlePanEnd();

    // Environment/weather config: dynamic, distinctive sun angle, and two
    // keyframes with distinct, non-default intensities.
    draftState.setDynamicWeather(true);
    draftState.setSunAngle(0.2);
    const firstKeyframe = WeatherKeyframe(
      atProgress: 0,
      windStrength: 0.3,
      rainIntensity: 0.4,
      snowIntensity: 0.1,
      fogDensity: 0.2,
      cloudCover: 0.6,
    );
    draftState.replaceKeyframe(0, firstKeyframe);
    draftState.addKeyframe();
    draftState.replaceKeyframe(
      1,
      const WeatherKeyframe(
        atProgress: 1,
        windStrength: 0.9,
        rainIntensity: 0.05,
        snowIntensity: 0.8,
        fogDensity: 0.5,
        cloudCover: 0.3,
      ),
    );

    // Wave 1 gets a hand-authored, non-procedural unit budget.
    draftState.setWaveUnitCount(UnitKind.tank, 5);

    final draft = draftState.draft.value;
    expect(draft.homeSites, hasLength(1));
    expect(draft.environment.timeline, hasLength(2));
    expect(draft.treeCells.any((t) => t.col == 20 && t.row == 10), isTrue);

    // 1. The exported/re-imported draft JSON (what `download`/`upload`
    // round-trip) must carry every field losslessly.
    final reloadedDraft = MapDraft.fromJson(
      jsonDecode(jsonEncode(draft.toJson())) as Map<String, dynamic>,
    );
    expect(reloadedDraft, draft);

    // 2. Run the actual production test-play pipeline.
    final persistenceState = MapEditorPersistenceState(
      draftState,
      _UnusedMapDraftRepository(),
    );
    addTearDown(persistenceState.dispose);
    final args = await persistenceState.preparePlay();

    final scene = args.scene;
    expect(scene.biome, draft.biome);
    expect(scene.waveCount, draft.waveCount);
    expect(scene.startingGold, draft.startingGold);
    expect(scene.environment, draft.environment);

    // The scene's own exported JSON ("scene results json") must also
    // carry the full environment/weather config losslessly.
    final reloadedScene = GameScene.fromJson(
      jsonDecode(jsonEncode(scene.toJson())) as Map<String, dynamic>,
    );
    expect(reloadedScene.environment, draft.environment);
    expect(reloadedScene.biome, draft.biome);
    expect(reloadedScene.waveCount, draft.waveCount);
    expect(reloadedScene.startingGold, draft.startingGold);

    // The generated terrain reflects the draft's arena size/biome and the
    // author-placed home site (not the west-edge default).
    final terrainRepository = args.terrainRepository!;
    final terrainMap = terrainRepository.loadTerrain(scene: scene);
    expect(terrainMap.arenaWidth, draft.arenaWidth);
    expect(terrainMap.arenaHeight, draft.arenaHeight);
    expect(terrainMap.biome, draft.biome);
    expect(
      terrainMap.basePoint.x < draft.arenaWidth / 2,
      isTrue,
      reason:
          'placing a home site on the west edge should move the base '
          'off its east-edge default',
    );
    expect(
      terrainMap.treeCells.any((p) => p.x == 20 && p.y == 10),
      isTrue,
      reason:
          'a hand-placed tree should reach the real terrain regardless of biome',
    );
    expect(
      terrainMap.biomeAt(11, 1),
      Biome.frozenPeaks,
      reason:
          "a mountain painted with a brush-type override should render "
          "with that biome's palette, not the map's own biome",
    );
    expect(
      terrainMap.biomeAt(10, 1),
      draft.biome,
      reason: 'a mountain painted with no override still renders with the '
          "map's own biome",
    );

    // The generated wave definition reflects the author's per-wave unit
    // budget instead of the procedural fallback.
    final waveRepository = args.waveRepository!;
    final wave1 = waveRepository.waveDefinition(1);
    expect(
      wave1.spawns.any(
        (spawn) => spawn.type == UnitKind.tank && spawn.count == 5,
      ),
      isTrue,
    );
  });
}

/// Never actually called by [MapEditorPersistenceState.preparePlay] (only
/// save/upload touch the repository), but the constructor requires one.
class _UnusedMapDraftRepository implements MapDraftRepository {
  @override
  Future<void> deleteDraft(String id) => throw UnimplementedError();

  @override
  Future<List<MapDraft>> listDrafts() => throw UnimplementedError();

  @override
  Future<MapDraft?> loadDraft(String id) => throw UnimplementedError();

  @override
  Future<void> saveDraft(MapDraft draft) => throw UnimplementedError();
}
