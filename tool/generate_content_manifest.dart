// One-off generator: converts today's hardcoded Tower/Building/MobileUnit
// blueprints into the versioned `GameObjectDefinition` JSON manifest,
// writing the same content to both the server's copy (served verbatim by
// `server/gemini_proxy.dart`'s `/content-manifest` route - "the database"
// for now, per-file until a real one replaces it) and the client's bundled
// seed asset (so the game has full content with zero network / in tests).
//
// Run with: dart run tool/generate_content_manifest.dart
// Re-run whenever a tower/building/unit blueprint's hardcoded stats change,
// then bump the affected entries' `version` by hand before committing.
import 'dart:convert';
import 'dart:io';

import 'package:boomspire/core/combat/mobile_unit_repository_impl.dart';
import 'package:boomspire/core/combat/team.dart';
import 'package:boomspire/features/game_content/domain/models/build_requirement.dart';
import 'package:boomspire/features/game_content/domain/models/game_object_definition.dart';
import 'package:boomspire/features/game_content/impl/game_object_definition_mapper.dart';
import 'package:boomspire/features/game_core/domain/models/game_config.dart';
import 'package:boomspire/features/towers/domain/models/building_type.dart';
import 'package:boomspire/features/towers/domain/models/tower_type.dart';
import 'package:boomspire/features/towers/impl/building_repository_impl.dart';
import 'package:boomspire/features/towers/impl/tower_repository_impl.dart';

/// Mirrors `BoomspireGame.buildBlockReason`'s hardcoded gates - the one
/// piece of today's logic that isn't itself sitting in a repo yet, so it's
/// transcribed here by hand rather than converted from existing data.
List<BuildRequirement> _requirementsForTower(TowerType type) => switch (type) {
  TowerType.laser => const [BuildingExistsRequirement('building.techLab')],
  TowerType.artilleryBunker => const [
    BuildingExistsRequirement('building.commandPost'),
  ],
  TowerType.sam || TowerType.rocketSilo => const [
    BuildingExistsRequirement('building.techLab'),
    BuildingExistsRequirement('building.commandPost'),
  ],
  _ => const [],
};

List<BuildRequirement> _requirementsForBuilding(BuildingType type) =>
    switch (type) {
      BuildingType.trainingCenter => const [
        ScoreRequirement(GameConfig.trainingCenterUnlockScore),
      ],
      BuildingType.warFactory => const [
        ScoreRequirement(GameConfig.warFactoryUnlockScore),
      ],
      _ => const [],
    };

List<String> _producibleUnitIdsFor(BuildingType type) => switch (type) {
  BuildingType.trainingCenter => const [
    'unit.buildable.soldier',
    'unit.buildable.antiTankSoldier',
    'unit.buildable.antiAirSoldier',
  ],
  // War Factory: "any buildable unit of their choosing" minus whatever the
  // Training Center already covers - see `war_factory_component.dart`.
  BuildingType.warFactory => const [
    'unit.buildable.tank',
    'unit.buildable.lightVehicle',
    'unit.buildable.aircraft',
    'unit.buildable.rocketBarrage',
  ],
  _ => const [],
};

void main() {
  final definitions = <GameObjectDefinition>[
    for (final blueprint in TowerRepositoryImpl().all)
      towerToDefinition(
        blueprint,
        requirements: _requirementsForTower(blueprint.type as TowerType),
      ),
    for (final blueprint in BuildingRepositoryImpl().all)
      buildingToDefinition(
        blueprint,
        requirements: _requirementsForBuilding(blueprint.type as BuildingType),
        producibleUnitIds: _producibleUnitIdsFor(blueprint.type as BuildingType),
      ),
    for (final team in [Team.invaders, Team.defaultPlayer])
      for (final kind in MobileUnitRepositoryImpl().kindsFor(team))
        mobileUnitToDefinition(
          MobileUnitRepositoryImpl().blueprintFor(team, kind),
          team.catalog,
        ),
  ];

  final json = const JsonEncoder.withIndent(
    '  ',
  ).convert(definitions.map((d) => d.toJson()).toList());

  File('server/content_manifest.json').writeAsStringSync('$json\n');
  File(
    'assets/game_content/manifest.json',
  ).createSync(recursive: true);
  File('assets/game_content/manifest.json').writeAsStringSync('$json\n');

  stdout.writeln('Wrote ${definitions.length} game object definitions.');
}
