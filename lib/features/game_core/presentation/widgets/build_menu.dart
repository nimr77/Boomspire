import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../towers/domain/models/tower_blueprint.dart';
import '../../../towers/domain/models/tower_type.dart';
import '../../../towers/presentation/tower_sprites.dart';
import '../boomspire_game.dart';

/// Horizontal row of construction cameo buttons docked at the right end of
/// the bottom command bar (see [HudOverlay]) - one square button per tower
/// type, with a cost badge.
class BuildMenu extends StatelessWidget {
  final BoomspireGame game;

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
                    final lockReason = game.buildBlockReason(bp.type);
                    final affordable = game.gameState.gold >= bp.cost;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _TowerButton(
                        blueprint: bp,
                        selected: selected == bp.type,
                        enabled: affordable && lockReason == null,
                        lockReason: lockReason,
                        builtCount: game.towerCountFor(bp.type),
                        limit: game.buildLimitFor(bp.type),
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

/// Frosted-glass hover card: build cost, core stats, and (when relevant)
/// the build-limit count and unlock requirement for a tower type.
class _GlassTooltip extends StatelessWidget {
  final TowerBlueprint blueprint;
  final String? lockReason;
  final int builtCount;
  final int? limit;

  const _GlassTooltip({
    required this.blueprint,
    required this.lockReason,
    required this.builtCount,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    Widget stat(IconData icon, String value) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white70),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blueprint.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    stat(Icons.paid, '${blueprint.cost}g'),
                    if (blueprint.damage > 0)
                      stat(Icons.flash_on, blueprint.damage.toStringAsFixed(0)),
                    if (blueprint.range > 0)
                      stat(
                        Icons.social_distance,
                        blueprint.range.toStringAsFixed(0),
                      ),
                    if (blueprint.damage > 0)
                      stat(
                        Icons.timer,
                        '${blueprint.fireRate.toStringAsFixed(1)}s',
                      ),
                    if (blueprint.splashRadius > 0)
                      stat(
                        Icons.blur_circular,
                        blueprint.splashRadius.toStringAsFixed(0),
                      ),
                  ],
                ),
                if (limit != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '$builtCount / $limit built',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (lockReason != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 12,
                        color: Colors.amberAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lockReason!,
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TowerButton extends StatefulWidget {
  final TowerBlueprint blueprint;

  final bool selected;
  final bool enabled;
  final String? lockReason;
  final int builtCount;
  final int? limit;
  final VoidCallback onTap;
  const _TowerButton({
    required this.blueprint,
    required this.selected,
    required this.enabled,
    required this.lockReason,
    required this.builtCount,
    required this.limit,
    required this.onTap,
  });

  @override
  State<_TowerButton> createState() => _TowerButtonState();
}

class _TowerButtonState extends State<_TowerButton> {
  final LayerLink _link = LayerLink();
  bool _hovering = false;
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    final blueprint = widget.blueprint;
    final selected = widget.selected;
    final locked = widget.lockReason != null;
    final accent = TowerSpriteFactory.accentColor(blueprint.type);
    final glowing = selected || _hovering;
    return CompositedTransformTarget(
      link: _link,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.45,
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _hovering = true);
            _showTooltip();
          },
          onExit: (_) {
            setState(() => _hovering = false);
            _hideTooltip();
          },
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
                            TowerType.techLab => Icons.biotech,
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
                  if (widget.limit != null)
                    Positioned(
                      left: 3,
                      top: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${widget.builtCount}/${widget.limit}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (locked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock,
                            color: Colors.white70,
                            size: 20,
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

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showTooltip() {
    _hideTooltip();
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 190,
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -10),
          child:
              _GlassTooltip(
                    blueprint: widget.blueprint,
                    lockReason: widget.lockReason,
                    builtCount: widget.builtCount,
                    limit: widget.limit,
                  )
                  .animate()
                  .fadeIn(duration: 140.ms, curve: Curves.easeOut)
                  .scaleXY(begin: 0.92, duration: 140.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.06, duration: 140.ms, curve: Curves.easeOut),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }
}
