import '../../../generated/l10n.dart';
import '../domain/models/building_type.dart';
import '../domain/models/unit_blueprint.dart';
import '../domain/repos/building_repository.dart';

class BuildingRepositoryImpl implements BuildingRepository {
  Map<BuildingType, UnitBlueprint> get _blueprints =>
      <BuildingType, UnitBlueprint>{
        BuildingType.techLab: UnitBlueprint(
          type: BuildingType.techLab,
          name: S.current.buildingNameTechLab,
          cost: 200,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 70,
        ),
        BuildingType.commandPost: UnitBlueprint(
          type: BuildingType.commandPost,
          name: S.current.buildingNameCommandPost,
          cost: 280,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 110,
        ),
        BuildingType.trainingCenter: UnitBlueprint(
          type: BuildingType.trainingCenter,
          name: S.current.buildingNameTrainingCenter,
          cost: 240,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 90,
        ),
        BuildingType.warFactory: UnitBlueprint(
          type: BuildingType.warFactory,
          name: S.current.buildingNameWarFactory,
          cost: 320,
          range: 0,
          damage: 0,
          fireRate: 1,
          maxHp: 140,
        ),
      };

  @override
  List<UnitBlueprint> get all => _blueprints.values.toList(growable: false);

  @override
  UnitBlueprint blueprintFor(BuildingType type) => _blueprints[type]!;
}
