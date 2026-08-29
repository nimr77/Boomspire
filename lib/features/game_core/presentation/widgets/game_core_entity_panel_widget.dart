import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/combat/unit_kind.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../generated/l10n.dart';
import '../../../../shared/app_theme/app_theme_colors.dart';
import '../../../../shared/app_theme/app_theme_paddings.dart';
import '../../../../shared/app_theme/app_theme_spacing.dart';
import '../../../combat/presentation/mobile_unit_component.dart';
import '../../../towers/presentation/gold_mine_component.dart';
import '../../../towers/presentation/tower_component.dart';
import '../../../towers/presentation/tower_sprites.dart';
import '../../../towers/presentation/training_center_component.dart';
import '../../../towers/presentation/war_factory_component.dart';
import '../../domain/models/inspected_info.dart';
import '../boomspire_game.dart';
import '../state/game_core_production_state.dart';
import 'game_core_entity_panel_shell_widget.dart';
import 'game_core_tower_action_button_widget.dart';
import 'game_core_tower_action_stat_chip_widget.dart';
import 'game_core_unit_fire_stats_widget.dart';

/// The single info+menu card docked next to the minimap in the bottom
/// command bar - whatever the player last selected or tapped (a built
/// tower/building, a unit under their control, or a read-only inspection of
/// anything else) renders through this ONE [GameCoreEntityPanelShellWidget],
/// just with different header/body content. A selected Training
/// Center/War Factory's produce-unit buttons live right alongside its
/// repair/upgrade/sell actions here too - one panel, not several.
class GameCoreEntityPanelWidget extends StatefulWidget {
  final BoomspireGame game;

  const GameCoreEntityPanelWidget({super.key, required this.game});

  @override
  State<GameCoreEntityPanelWidget> createState() =>
      _GameCoreEntityPanelWidgetState();
}

class _GameCoreEntityPanelWidgetState extends State<GameCoreEntityPanelWidget> {
  Timer? _pollTimer;
  final ValueNotifier<int> _tick = ValueNotifier(0);
  late final GameCoreProductionState _productionState;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return ListenableBuilder(
      listenable: Listenable.merge([
        game.selectedTower,
        game.selectedUnit,
        game.inspected,
        game.gameState,
        _tick,
      ]),
      builder: (context, _) {
        final content = _contentFor(game);
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
          child: content ?? const SizedBox.shrink(key: ValueKey('no-panel')),
        );
      },
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _tick.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _productionState = getIt<GameCoreProductionState>();
    // A tower's HP and a unit's health both change continuously from
    // combat (Flame components, not Listenables) - poll at a modest rate
    // so the card stays live without wiring a full ChangeNotifier through
    // either one.
    _pollTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted &&
          (widget.game.selectedTower.value != null ||
              widget.game.selectedUnit.value != null)) {
        _tick.value++;
      }
    });
  }

  Widget _buildInspectedPanel(BoomspireGame game, InspectedInfo info) {
    final ownerColor = info.owner?.color ?? AppThemeColors.textSecondary;
    final icon = switch (info.kind) {
      InspectedKind.tower => Icons.apartment,
      InspectedKind.unit => Icons.directions_walk,
      InspectedKind.resourceNode => Icons.diamond,
    };
    Widget? child;
    if (info.unitBlueprint != null) {
      child = GameCoreUnitFireStatsWidget(
        blueprint: info.unitBlueprint!,
        accentColor: ownerColor,
      );
    } else if (info.description != null) {
      child = Text(
        info.description!,
        style: const TextStyle(color: AppThemeColors.textMuted, fontSize: 11),
      );
    }
    return GameCoreEntityPanelShellWidget(
      key: ValueKey(info),
      icon: icon,
      accentColor: ownerColor,
      title: info.name,
      ownerLabel: info.owner?.label ?? S.current.unclaimedLabelEntityPanel,
      ownerColor: ownerColor,
      onClose: () => game.inspected.value = null,
      child: child,
    );
  }

  Widget _buildOwnUnitPanel(BoomspireGame game, MobileUnitComponent unit) {
    return GameCoreEntityPanelShellWidget(
      key: ValueKey(unit),
      icon: Icons.directions_walk,
      accentColor: unit.team.color,
      title: unit.blueprint.name,
      subtitle: S.current.hpLabelEntityPanel(
        unit.health.ceil(),
        unit.effectiveMaxHealth.ceil(),
      ),
      ownerLabel: unit.team.label,
      ownerColor: unit.team.color,
      onClose: () => game.selectedUnit.value = null,
      child: GameCoreUnitFireStatsWidget(
        blueprint: unit.blueprint,
        accentColor: unit.team.color,
      ),
    );
  }

  Widget _buildTowerPanel(BoomspireGame game, TowerComponent tower) {
    final accent = TowerSpriteFactory.accentColor(tower.blueprint.type);
    final producing =
        tower is TrainingCenterComponent || tower is WarFactoryComponent;
    return GameCoreEntityPanelShellWidget(
      key: ValueKey(tower),
      icon: Icons.apartment,
      accentColor: accent,
      title: tower.blueprint.name,
      subtitle:
          S.current.hpLabelEntityPanel(tower.hp.ceil(), tower.maxHp.ceil()) +
          (tower.upgradeLevel > 0
              ? '  •  ${S.current.towerTier(tower.upgradeLevel + 1)}'
              : ''),
      onClose: () => game.selectedTower.value = null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _divider(),
          GameCoreTowerActionButtonWidget(
            icon: Icons.build,
            label: tower.repairCost > 0 ? '${tower.repairCost}g' : '-',
            enabled:
                tower.repairCost > 0 && game.gameState.gold >= tower.repairCost,
            onTap: game.repairSelectedTower,
          ),
          SizedBox(width: AppThemeSpacing.space6),
          GameCoreTowerActionButtonWidget(
            icon: Icons.upgrade,
            label: tower.canUpgrade
                ? '${tower.upgradeCost}g'
                : S.current.towerMax,
            enabled:
                tower.canUpgrade && game.gameState.gold >= tower.upgradeCost,
            onTap: game.upgradeSelectedTower,
          ),
          SizedBox(width: AppThemeSpacing.space6),
          GameCoreTowerActionButtonWidget(
            icon: Icons.gpp_good,
            label: tower.antiRocket
                ? S.current.activeLabelEntityPanel
                : '${kAntiRocketCost}g',
            color: AppThemeColors.accentCyan,
            enabled:
                !tower.antiRocket && game.gameState.gold >= kAntiRocketCost,
            onTap: game.buyAntiRocketForSelectedTower,
          ),
          SizedBox(width: AppThemeSpacing.space6),
          GameCoreTowerActionButtonWidget(
            icon: Icons.sell,
            label: '+${tower.sellValue}g',
            enabled: true,
            color: AppThemeColors.accentRed,
            onTap: game.sellSelectedTower,
          ),

          if (tower is GoldMineComponent) ...[
            SizedBox(width: AppThemeSpacing.space4),
            _divider(),
            SizedBox(width: AppThemeSpacing.space10),
            for (final chip in _goldMineChips(tower)) ...[
              chip,
              SizedBox(width: AppThemeSpacing.space8),
            ],
          ],
        ],
      ),
      child: producing
          ? Padding(
              padding: AppThemePaddings.top5,
              child: Row(
                children: [
                  for (final button in _produceButtons(game, tower)) ...[
                    button,
                    SizedBox(width: AppThemeSpacing.space6),
                  ],
                ],
              ),
            )
          : null,
    );
  }

  Widget? _contentFor(BoomspireGame game) {
    final tower = game.selectedTower.value;
    if (tower != null) return _buildTowerPanel(game, tower);
    final unit = game.selectedUnit.value;
    if (unit != null && !unit.destroyed) return _buildOwnUnitPanel(game, unit);
    final info = game.inspected.value;
    if (info != null) return _buildInspectedPanel(game, info);
    return null;
  }

  Widget _divider() => Container(
    margin: AppThemePaddings.h4,
    width: 1,
    height: 34,
    color: AppThemeColors.borderSubtle,
  );

  List<Widget> _goldMineChips(GoldMineComponent tower) {
    return [
      GameCoreTowerActionStatChipWidget(
        icon: Icons.paid,
        label: S.current.goldMinePayoutIn(
          tower.payoutAmount,
          tower.payoutTimeRemaining.ceil(),
        ),
        color: AppThemeColors.accentGold,
      ),
      GameCoreTowerActionStatChipWidget(
        icon: Icons.local_fire_department,
        label: S.current.goldMineKillBonus((tower.killGoldBonus * 100).round()),
        color: AppThemeColors.accentDeepOrange,
      ),
    ];
  }

  List<Widget> _produceButtons(BoomspireGame game, TowerComponent tower) {
    return [
      for (final option in _productionState.optionsFor(game, tower))
        GameCoreTowerActionButtonWidget(
          icon: _unitIcon(option.kind),
          label:
              option.lockReason ??
              (option.ready
                  ? '${option.cost}g'
                  : '${option.cooldownRemaining.ceil()}s'),
          color: AppThemeColors.accentEmerald,
          enabled: option.affordable,
          onTap: () => _productionState.produce(tower, option.kind),
        ),
    ];
  }

  IconData _unitIcon(UnitKind type) => switch (type) {
    UnitKind.tank => Icons.local_shipping,
    UnitKind.lightVehicle => Icons.directions_car,
    UnitKind.aircraft => Icons.flight,
    UnitKind.rocketBarrage => Icons.rocket_launch,
    UnitKind.heavySoldier => Icons.security,
    UnitKind.helicopter => Icons.airline_seat_recline_extra,
    UnitKind.attackPlane => Icons.flight_takeoff,
    UnitKind.artilleryBarrage => Icons.gps_fixed,
    UnitKind.antiTankSoldier => Icons.gps_fixed,
    UnitKind.antiAirSoldier => Icons.arrow_circle_up,
    UnitKind.stealthBomber => Icons.airplanemode_active,
    _ => Icons.directions_walk,
  };
}
