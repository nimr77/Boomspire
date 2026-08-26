import '../models/tower_blueprint.dart';
import '../models/tower_type.dart';

/// Catalog of buildable tower types and their stats.
abstract class TowerRepository {
  List<TowerBlueprint> get all;
  TowerBlueprint blueprintFor(TowerType type);
}
