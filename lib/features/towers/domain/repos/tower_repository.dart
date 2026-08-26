import '../models/tower_blueprint.dart';
import '../models/tower_type.dart';

/// Catalog of buildable tower types and their stats.
abstract class TowerRepository {
  TowerBlueprint blueprintFor(TowerType type);
  List<TowerBlueprint> get all;
}
