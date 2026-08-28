import '../../../game_content/domain/models/build_requirement.dart';
import '../models/tower_type.dart';
import '../models/unit_blueprint.dart';

/// Catalog of buildable combat tower types and their stats.
abstract class TowerRepository {
  List<UnitBlueprint> get all;
  UnitBlueprint blueprintFor(TowerType type);
  List<BuildRequirement> requirementsFor(TowerType type);
}
