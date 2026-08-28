import '../../../generated/l10n.dart';
import '../../game_content/domain/models/build_requirement.dart';
import '../../game_content/domain/models/default_build_requirements.dart';
import '../../game_content/domain/models/game_object_definition.dart';
import '../../game_content/impl/game_object_definition_mapper.dart';
import '../domain/models/building_type.dart';
import '../domain/models/unit_blueprint.dart';
import '../domain/repos/building_repository.dart';

class BuildingRepositoryImpl implements BuildingRepository {
  /// Synced game-content overrides (see `GameContentSyncService`) - empty
  /// by default, so every existing call site (including every test) gets
  /// today's hardcoded stats unchanged unless a successful sync supplied
  /// something newer.
  final List<GameObjectDefinition> overrides;

  BuildingRepositoryImpl({this.overrides = const []});

  @override
  List<UnitBlueprint> get all =>
      _resolvedBlueprints.values.toList(growable: false);

  Map<BuildingType, UnitBlueprint> get _blueprints =>
      <BuildingType, UnitBlueprint>{
        BuildingType.techLab: UnitBlueprint(
          type: BuildingType.techLab,
          name: S.current.buildingNameTechLab,
          cost: 500,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 200,
        ),
        BuildingType.commandPost: UnitBlueprint(
          type: BuildingType.commandPost,
          name: S.current.buildingNameCommandPost,
          cost: 600,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 200,
        ),
        BuildingType.trainingCenter: UnitBlueprint(
          type: BuildingType.trainingCenter,
          name: S.current.buildingNameTrainingCenter,
          cost: 550,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 200,
        ),
        BuildingType.warFactory: UnitBlueprint(
          type: BuildingType.warFactory,
          name: S.current.buildingNameWarFactory,
          cost: 700,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 200,
        ),
        BuildingType.goldMine: UnitBlueprint(
          type: BuildingType.goldMine,
          name: S.current.buildingNameGoldMine,
          cost: 250,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 200,
        ),
        BuildingType.powerPlant: UnitBlueprint(
          type: BuildingType.powerPlant,
          name: S.current.buildingNamePowerPlant,
          cost: 350,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 200,
        ),
      };

  Map<BuildingType, UnitBlueprint> get _resolvedBlueprints {
    final blueprints = _blueprints;
    for (final type in BuildingType.values) {
      final override = findOverride(overrides, buildingDefinitionId(type));
      if (override != null) {
        blueprints[type] = applyBuildingOverride(blueprints[type]!, override);
      }
    }
    return blueprints;
  }

  @override
  UnitBlueprint blueprintFor(BuildingType type) => _resolvedBlueprints[type]!;

  @override
  List<BuildRequirement> requirementsFor(BuildingType type) =>
      findOverride(overrides, buildingDefinitionId(type))?.requirements ??
      defaultRequirementsForBuilding(type);
}
