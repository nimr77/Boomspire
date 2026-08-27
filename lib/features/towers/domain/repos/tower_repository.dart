import '../models/tower_type.dart';
import '../models/unit_blueprint.dart';

/// Catalog of buildable combat tower types and their stats.
abstract class TowerRepository {
  List<UnitBlueprint> get all;
  UnitBlueprint blueprintFor(TowerType type);
}
