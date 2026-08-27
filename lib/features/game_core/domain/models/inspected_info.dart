import '../../../../core/combat/team.dart';

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

/// Which kind of thing is being shown in the read-only inspect panel -
/// picks the icon `InspectPanel` renders.
enum InspectedKind { tower, unit, resourceNode }
