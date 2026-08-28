import '../../../game_core/domain/models/game_config.dart';
import '../../../towers/domain/models/building_type.dart';
import '../../../towers/domain/models/tower_type.dart';
import 'build_requirement.dart';

/// Same as [defaultRequirementsForTower], for support buildings.
List<BuildRequirement> defaultRequirementsForBuilding(BuildingType type) =>
    switch (type) {
      BuildingType.powerPlant => const [MaxCountRequirement(1)],
      BuildingType.techLab => const [
        BuildingExistsRequirement('building.powerPlant'),
        MaxCountRequirement(1),
      ],
      BuildingType.commandPost => const [
        AnyBuildingExistsRequirement([
          'building.warFactory',
          'building.trainingCenter',
        ]),
        MaxCountRequirement(1),
      ],
      BuildingType.trainingCenter => const [
        ScoreRequirement(GameConfig.trainingCenterUnlockScore),
      ],
      BuildingType.warFactory => const [
        ScoreRequirement(GameConfig.warFactoryUnlockScore),
      ],
      _ => const [],
    };

/// The game's built-in prerequisite/build-limit rules for every combat
/// tower - the single source of truth consulted both by
/// `BoomspireGame.buildBlockReason`/`buildLimitFor` (as the fallback
/// whenever `GameContentSyncService` hasn't supplied a server override for
/// that type's `GameObjectDefinition.requirements`) and by
/// `tool/generate_content_manifest.dart` (to seed the shipped manifest) -
/// keeping both in one place means the manifest and the client's offline
/// fallback can never drift apart.
List<BuildRequirement> defaultRequirementsForTower(TowerType type) =>
    switch (type) {
      TowerType.laser => const [
        BuildingExistsRequirement('building.techLab'),
        MaxCountRequirement(1),
      ],
      TowerType.artilleryBunker => const [
        BuildingExistsRequirement('building.commandPost'),
      ],
      TowerType.sam => const [
        BuildingExistsRequirement('building.techLab'),
        BuildingExistsRequirement('building.commandPost'),
        MaxCountRequirement(2),
      ],
      TowerType.rocketSilo => const [
        BuildingExistsRequirement('building.techLab'),
        BuildingExistsRequirement('building.commandPost'),
        MaxCountRequirement(1),
      ],
      _ => const [],
    };
