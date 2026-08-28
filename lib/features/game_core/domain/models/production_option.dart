import '../../../../core/combat/unit_kind.dart';

/// One buildable-unit row for a Training Center/War Factory's produce menu,
/// as computed by `GameCoreProductionState` - a read-only UI projection,
/// never persisted.
class ProductionOption {
  final UnitKind kind;
  final bool ready;
  final double cooldownRemaining;
  final int cost;
  final bool affordable;

  /// Why this kind can't be produced right now regardless of gold/cooldown
  /// (e.g. `'Requires Command Post'`) - null if there's no prerequisite
  /// blocking it. See `BoomspireGame.unitBlockReason`.
  final String? lockReason;

  const ProductionOption({
    required this.kind,
    required this.ready,
    required this.cooldownRemaining,
    required this.cost,
    required this.affordable,
    this.lockReason,
  });
}
