import '../../../game_content/domain/models/build_requirement.dart';
import '../models/building_type.dart';
import '../models/unit_blueprint.dart';

/// Catalog of buildable support-building types and their stats.
abstract class BuildingRepository {
  List<UnitBlueprint> get all;
  UnitBlueprint blueprintFor(BuildingType type);
  List<BuildRequirement> requirementsFor(BuildingType type);
}
