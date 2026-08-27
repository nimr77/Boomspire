import '../models/ally_unit_blueprint.dart';
import '../models/ally_unit_type.dart';

/// Catalog of buildable friendly unit types and their stats.
abstract class AllyUnitRepository {
  AllyUnitBlueprint blueprintFor(AllyUnitType type);
}
