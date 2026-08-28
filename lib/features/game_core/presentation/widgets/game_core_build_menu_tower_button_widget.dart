import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../theme/app_theme/app_theme_colors.dart';
import '../../../../theme/app_theme/app_theme_paddings.dart';
import '../../../../theme/app_theme/app_theme_spacing.dart';
import '../../../towers/domain/models/building_type.dart';
import '../../../towers/domain/models/tower_type.dart';
import '../../../towers/domain/models/unit_blueprint.dart';
import '../../../towers/presentation/tower_sprites.dart';
import 'game_core_build_menu_glass_tooltip_widget.dart';

/// One square construction cameo button in [BuildMenu] - shows a hover/
/// selection glow and a floating cost/lock tooltip via an [OverlayEntry].
class GameCoreBuildMenuTowerButtonWidget extends StatefulWidget {
  final UnitBlueprint blueprint;

  final bool selected;
  final bool enabled;
  final String? lockReason;
  final int builtCount;
  final int? limit;
  final VoidCallback onTap;
  const GameCoreBuildMenuTowerButtonWidget({
    super.key,
    required this.blueprint,
    required this.selected,
    required this.enabled,
    required this.lockReason,
    required this.builtCount,
    required this.limit,
    required this.onTap,
  });

  @override
  State<GameCoreBuildMenuTowerButtonWidget> createState() =>
      _GameCoreBuildMenuTowerButtonWidgetState();
}

class _GameCoreBuildMenuTowerButtonWidgetState
    extends State<GameCoreBuildMenuTowerButtonWidget> {
  final LayerLink _link = LayerLink();
  final ValueNotifier<bool> _hovering = ValueNotifier(false);
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    final blueprint = widget.blueprint;
    final selected = widget.selected;
    final locked = widget.lockReason != null;
    final accent = TowerSpriteFactory.accentColor(blueprint.type);
    return CompositedTransformTarget(
      link: _link,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.45,
        child: MouseRegion(
          onEnter: (_) {
            _hovering.value = true;
            _showTooltip();
          },
          onExit: (_) {
            _hovering.value = false;
            _hideTooltip();
          },
          child: InkWell(
            onTap: widget.enabled ? widget.onTap : null,
            borderRadius: BorderRadius.circular(8),
            child: ValueListenableBuilder<bool>(
              valueListenable: _hovering,
              builder: (context, hovering, _) {
                final glowing = selected || hovering;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  width: 84,
                  transform: Matrix4.identity()
                    ..scaleByDouble(
                      hovering ? 1.06 : 1.0,
                      hovering ? 1.06 : 1.0,
                      1.0,
                      1.0,
                    ),
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppThemeColors.surfacePanel,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: glowing ? accent : AppThemeColors.borderSubtle,
                      width: selected ? 2.5 : (hovering ? 2 : 1),
                    ),
                    boxShadow: glowing
                        ? [
                            BoxShadow(
                              color: accent.withValues(
                                alpha: selected ? 0.5 : 0.35,
                              ),
                              blurRadius: selected ? 10 : 14,
                              spreadRadius: hovering ? 1 : 0,
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
                                TowerType.rocketSilo => Icons.rocket_launch,
                                TowerType.artilleryBunker => Icons.fort,
                                TowerType.sam => Icons.satellite_alt,
                                BuildingType.techLab => Icons.biotech,
                                BuildingType.commandPost => Icons.cell_tower,
                                BuildingType.trainingCenter => Icons.groups,
                                BuildingType.warFactory => Icons.factory,
                                BuildingType.goldMine => Icons.diamond,
                                _ => Icons.help_outline,
                              },
                              color: accent,
                              size: 22,
                            ),
                            SizedBox(height: AppThemeSpacing.space3),
                            Text(
                              blueprint.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppThemeColors.textPrimary,
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
                          padding: AppThemePaddings.h5v1,
                          decoration: BoxDecoration(
                            color: AppThemeColors.overlayChipBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${blueprint.cost}g',
                            style: const TextStyle(
                              color: AppThemeColors.accentAmber,
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
                            padding: AppThemePaddings.h4v1,
                            decoration: BoxDecoration(
                              color: AppThemeColors.overlayChipBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${widget.builtCount}/${widget.limit}',
                              style: const TextStyle(
                                color: AppThemeColors.textMuted,
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
                              color: AppThemeColors.overlayLockScrim,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.lock,
                                color: AppThemeColors.textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideTooltip();
    _hovering.dispose();
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
              GameCoreBuildMenuGlassTooltipWidget(
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
