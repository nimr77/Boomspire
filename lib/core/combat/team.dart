import 'dart:ui';

import 'team_relation.dart';
import 'unit_catalog.dart';

export 'team_relation.dart';
export 'unit_catalog.dart';

/// Which side a mobile unit (or, in future, a structure) belongs to. Teams
/// are told apart purely by their numeric [id] - two teams with the same id
/// are the same side, any other pairing is hostile (see [relationTo]) -
/// instead of a single hardcoded "enemy" flag, so a scene can field any
/// number of AI factions and/or human player seats and have them all sort
/// out who's who the same way.
class Team {
  /// The AI-directed wave invaders - always red, regardless of how many
  /// other teams end up sharing the map.
  static const invaders = Team(
    id: 0,
    label: 'Invaders',
    catalog: UnitCatalog.invaderRoster,
    color: Color(0xFFE53935),
  );

  /// Default color/id for the (currently single) human player - matches the
  /// home base's original cyan livery. A player color/id picker/lobby (see
  /// the multiplayer plan) would construct its own [Team] with a chosen id
  /// and color instead of using this constant directly.
  static const defaultPlayer = Team(
    id: 1,
    label: 'Player 1',
    catalog: UnitCatalog.buildableRoster,
    color: Color(0xFF00E5FF),
  );

  /// The Gemini-directed skirmish opponent (see `AiSkirmishControllerComponent`)
  /// - builds/produces from the same roster the human player does, just from
  /// its own base/economy on a [GameMode.skirmish] map.
  static const aiOpponent = Team(
    id: 2,
    label: 'AI Commander',
    catalog: UnitCatalog.buildableRoster,
    color: Color(0xFFFF6D00),
  );

  /// Same [id] on two [Team]s means the same side - this is the only thing
  /// [relationTo] ever looks at.
  final int id;

  /// Human-readable name, for debugging/UI - never used for equality.
  final String label;

  /// Which `MobileUnitBlueprint` table this team's units/buildings draw
  /// from (see `MobileUnitRepository`).
  final UnitCatalog catalog;

  final Color color;

  const Team({
    required this.id,
    required this.label,
    required this.catalog,
    required this.color,
  });

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is Team && other.id == id;

  /// Same [id] as [other] means allied, anything else is hostile - the
  /// whole "who's the enemy" question, decided once, in one place.
  TeamRelation relationTo(Team other) =>
      id == other.id ? TeamRelation.ally : TeamRelation.enemy;

  @override
  String toString() => 'Team($id: $label)';
}
