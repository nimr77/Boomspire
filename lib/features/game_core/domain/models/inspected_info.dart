import '../../../../core/combat/team.dart';
import '../enums/inspected_kind.dart';

export '../enums/inspected_kind.dart';

/// A lightweight, read-only snapshot of whatever the player last tapped
/// that isn't theirs to command (an enemy-owned tower, any mobile unit, or
/// a resource node) - shown by `InspectPanel`. Deliberately not a full
/// domain model: it's a transient UI projection, never persisted.
class InspectedInfo {
  final InspectedKind kind;
  final String name;

  /// Null only for an unclaimed resource node.
  final Team? owner;
  final String? description;

  const InspectedInfo({
    required this.kind,
    required this.name,
    this.owner,
    this.description,
  });
}
