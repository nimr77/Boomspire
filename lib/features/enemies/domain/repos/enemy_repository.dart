import '../models/enemy_blueprint.dart';
import '../models/enemy_type.dart';

/// Catalog of enemy types and their stats.
abstract class EnemyRepository {
  EnemyBlueprint blueprintFor(EnemyType type);
}
