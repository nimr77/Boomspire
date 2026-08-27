import '../../../generated/l10n.dart';
import '../domain/models/building_type.dart';
import '../domain/models/unit_blueprint.dart';
import '../domain/repos/building_repository.dart';

class BuildingRepositoryImpl implements BuildingRepository {
  @override
  List<UnitBlueprint> get all => _blueprints.values.toList(growable: false);

  Map<BuildingType, UnitBlueprint> get _blueprints =>
      <BuildingType, UnitBlueprint>{
        BuildingType.techLab: UnitBlueprint(
          type: BuildingType.techLab,
          name: S.current.buildingNameTechLab,
          cost: 500,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 70,
        ),
        BuildingType.commandPost: UnitBlueprint(
          type: BuildingType.commandPost,
          name: S.current.buildingNameCommandPost,
          cost: 600,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 110,
        ),
        BuildingType.trainingCenter: UnitBlueprint(
          type: BuildingType.trainingCenter,
          name: S.current.buildingNameTrainingCenter,
          cost: 550,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 90,
        ),
        BuildingType.warFactory: UnitBlueprint(
          type: BuildingType.warFactory,
          name: S.current.buildingNameWarFactory,
          cost: 700,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 140,
        ),
      };

  @override
  UnitBlueprint blueprintFor(BuildingType type) => _blueprints[type]!;
}
