import 'package:flutter/material.dart';

import '../../../towers/domain/models/tower_blueprint.dart';
import '../../../towers/domain/models/tower_type.dart';
import '../../../towers/presentation/tower_sprites.dart';
import '../circuit_defense_game.dart';

/// Horizontal row of construction cameo buttons docked at the right end of
/// the bottom command bar (see [HudOverlay]) - one square button per tower
/// type, with a cost badge.
class BuildMenu extends StatelessWidget {
  final CircuitDefenseGame game;

  const BuildMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF2A323C), width: 2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ListenableBuilder(
        listenable: game.gameState,
        builder: (context, _) {
          return ValueListenableBuilder<TowerType?>(
            valueListenable: game.selectedTowerType,
            builder: (context, selected, _) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: game.towerRepository.all.map((bp) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _TowerButton(
                        blueprint: bp,
                        selected: selected == bp.type,
                        enabled: game.gameState.gold >= bp.cost,
                        onTap: () => game.selectTowerType(bp.type),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TowerButton extends StatefulWidget {
  final TowerBlueprint blueprint;

  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  const _TowerButton({
    required this.blueprint,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_TowerButton> createState() => _TowerButtonState();
}

class _TowerButtonState extends State<_TowerButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final blueprint = widget.blueprint;
    final selected = widget.selected;
    final accent = TowerSpriteFactory.accentColor(blueprint.type);
    final glowing = selected || _hovering;
    return Opacity(
      opacity: widget.enabled ? 1 : 0.45,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: Tooltip(
          waitDuration: const Duration(milliseconds: 300),
          richMessage: _statsLegend(blueprint),
          child: InkWell(
            onTap: widget.enabled ? widget.onTap : null,
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              width: 84,
              transform: Matrix4.identity()
                ..scaleByDouble(
                  _hovering ? 1.06 : 1.0,
                  _hovering ? 1.06 : 1.0,
                  1.0,
                  1.0,
                ),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: glowing ? accent : Colors.white24,
                  width: selected ? 2.5 : (_hovering ? 2 : 1),
                ),
                boxShadow: glowing
                    ? [
                        BoxShadow(
                          color: accent.withValues(
                            alpha: selected ? 0.5 : 0.35,
                          ),
                          blurRadius: selected ? 10 : 14,
                          spreadRadius: _hovering ? 1 : 0,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          switch (blueprint.type) {
                            TowerType.rocket => Icons.local_fire_department,
                            TowerType.cannon => Icons.whatshot,
                            TowerType.antiAir => Icons.radar,
                            TowerType.machineGun => Icons.gps_fixed,
                            TowerType.laser => Icons.bolt,
                          },
                          color: accent,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          blueprint.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 3,
                    bottom: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${blueprint.cost}g',
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// A small icon+number legend of this tower's core combat stats, shown as
  /// a native tooltip on hover.
  InlineSpan _statsLegend(TowerBlueprint blueprint) {
    Widget stat(IconData icon, String value) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white70),
          const SizedBox(width: 2),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
    return WidgetSpan(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          stat(Icons.flash_on, blueprint.damage.toStringAsFixed(0)),
          stat(Icons.social_distance, blueprint.range.toStringAsFixed(0)),
          stat(Icons.timer, '${blueprint.fireRate.toStringAsFixed(1)}s'),
          if (blueprint.splashRadius > 0)
            stat(
              Icons.blur_circular,
              blueprint.splashRadius.toStringAsFixed(0),
            ),
        ],
      ),
    );
  }
}
