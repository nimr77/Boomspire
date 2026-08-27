// Proves GameScene/HomeSite round-trip through JSON cleanly - the
// foundation a future data-driven scene/map builder reads and writes.
import 'package:boomspire/features/game_core/domain/models/game_scene.dart';
import 'package:boomspire/features/game_core/domain/models/game_scenes.dart';
import 'package:boomspire/features/terrain/domain/models/biome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wave-defense scene round-trips through JSON', () {
    final original = GameScenes.all.first;

    final decoded = GameScene.fromJson(original.toJson());

    expect(decoded.id, original.id);
    expect(decoded.name, original.name);
    expect(decoded.biome, original.biome);
    expect(decoded.mode, GameMode.waveDefense);
    expect(decoded.waveCount, original.waveCount);
    expect(decoded.aggressionBias, original.aggressionBias);
    expect(decoded.homeLayout, original.homeLayout);
    expect(decoded.spawnLayout, original.spawnLayout);
    expect(decoded.homeSites, isEmpty);
    expect(decoded.resourceNodeSites, isEmpty);
  });

  test('skirmish scene round-trips its homeSites through JSON', () {
    final original = GameScenes.skirmishes.first;

    final decoded = GameScene.fromJson(original.toJson());

    expect(decoded.mode, GameMode.skirmish);
    expect(decoded.homeSites.length, original.homeSites.length);
    for (var i = 0; i < original.homeSites.length; i++) {
      expect(decoded.homeSites[i].layout, original.homeSites[i].layout);
      expect(decoded.homeSites[i].owner, original.homeSites[i].owner);
    }
  });

  test('skirmish scene round-trips its resourceNodeSites through JSON', () {
    final original = GameScenes.skirmishes.first;

    final decoded = GameScene.fromJson(original.toJson());

    expect(decoded.resourceNodeSites.length, original.resourceNodeSites.length);
    for (var i = 0; i < original.resourceNodeSites.length; i++) {
      expect(decoded.resourceNodeSites[i].dx, original.resourceNodeSites[i].dx);
      expect(decoded.resourceNodeSites[i].dy, original.resourceNodeSites[i].dy);
    }
  });

  test('fromJson tolerates missing optional fields', () {
    final decoded = GameScene.fromJson({
      'id': 'bare',
      'name': 'Bare Scene',
      'briefing': 'Minimal JSON, only the required fields.',
      'biome': Biome.grassPlains.name,
    });

    expect(decoded.mode, GameMode.waveDefense);
    expect(decoded.waveCount, 0);
    expect(decoded.homeLayout, HomeLayout.eastEdge);
    expect(decoded.spawnLayout, SpawnLayout.single);
    expect(decoded.homeSites, isEmpty);
    expect(decoded.resourceNodeSites, isEmpty);
  });
}
