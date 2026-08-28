import 'package:flutter/material.dart';

import '../../../../core/combat/extensions/weapon_type_extensions.dart';
import '../../../../core/combat/mobile_unit_blueprint.dart';
import 'game_core_tower_action_stat_chip_widget.dart';

/// Row of stat chips describing a unit's attack profile (what it fires,
/// how hard, how far, how often) - the same content for every [UnitKind],
/// shown for both a player-controlled selected unit and a read-only
/// inspected one, so no unit kind needs its own bespoke info widget.
class GameCoreUnitFireStatsWidget extends StatelessWidget {
  final MobileUnitBlueprint blueprint;
  final Color accentColor;

  const GameCoreUnitFireStatsWidget({
    super.key,
    required this.blueprint,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (blueprint.attackDamage <= 0) return const SizedBox.shrink();
    final perShot = blueprint.attackDamage / blueprint.projectileCount;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        GameCoreTowerActionStatChipWidget(
          icon: blueprint.weaponType.icon,
          label: blueprint.weaponType.label,
          color: accentColor,
        ),
        GameCoreTowerActionStatChipWidget(
          icon: Icons.flash_on,
          label: blueprint.projectileCount > 1
              ? '${perShot.toStringAsFixed(0)} x${blueprint.projectileCount}'
              : perShot.toStringAsFixed(0),
          color: accentColor,
        ),
        GameCoreTowerActionStatChipWidget(
          icon: Icons.social_distance,
          label: blueprint.attackRange.toStringAsFixed(0),
          color: accentColor,
        ),
        GameCoreTowerActionStatChipWidget(
          icon: Icons.timer,
          label: '${blueprint.attackInterval.toStringAsFixed(1)}s',
          color: accentColor,
        ),
      ],
    );
  }
}
