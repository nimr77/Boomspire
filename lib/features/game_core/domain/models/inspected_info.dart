import '../../../../core/combat/mobile_unit_blueprint.dart';
import '../../../../core/combat/team.dart';
import '../enums/inspected_kind.dart';

export '../enums/inspected_kind.dart';

/// A lightweight, read-only snapshot of whatever the player last tapped
/// that isn't theirs to command (an enemy-owned tower, any mobile unit, or
/// a resource node) - shown by `GameCoreEntityPanelWidget`. Deliberately not
/// a full domain model: it's a transient UI projection, never persisted.
class InspectedInfo {
  final InspectedKind kind;
  final String name;

  /// Null only for an unclaimed resource node.
  final Team? owner;
  final String? description;

  /// Only set for [InspectedKind.unit] - lets the panel show what it fires.
  final MobileUnitBlueprint? unitBlueprint;

  const InspectedInfo({
    required this.kind,
    required this.name,
    this.owner,
    this.description,
    this.unitBlueprint,
  });
}
