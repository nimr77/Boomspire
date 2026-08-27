import 'dart:ui';

/// Which side a mobile unit (or, in future, a structure) belongs to. The
/// AI-controlled invaders are always [enemy]; every human-controlled
/// defender - just one today, more once real networked multiplayer seats
/// multiple players in the same match - gets their own [Team] instance so
/// their units can be tinted with their own color instead of one hardcoded
/// cyan, while still sharing the exact same `MobileUnitComponent`/
/// `MobileUnitRepository` code path as the enemy side.
class Team {
  final String id;
  final bool isEnemy;
  final Color color;

  const Team({required this.id, required this.isEnemy, required this.color});

  /// The AI-directed invaders - always red, regardless of how many human
  /// player teams end up sharing the map.
  static const enemy = Team(id: 'enemy', isEnemy: true, color: Color(0xFFE53935));

  /// Default color for the (currently single) human player - matches the
  /// home base's original cyan livery. A player color picker/lobby (see the
  /// multiplayer plan) would construct its own [Team] with a chosen color
  /// instead of using this constant directly.
  static const defaultPlayer = Team(
    id: 'player-1',
    isEnemy: false,
    color: Color(0xFF00E5FF),
  );

  @override
  bool operator ==(Object other) => other is Team && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Team($id)';
}
