import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/combat/team.dart';
import '../domain/models/game_config.dart';
import 'boomspire_game.dart';

/// A capturable second-resource node placed on a skirmish map (see
/// `GameScene.resourceNodeSites`). Whichever team keeps an uncontested
/// vehicle inside [GameConfig.resourceNodeCaptureRadius] for
/// [GameConfig.resourceNodeCaptureTime] seconds claims it; while claimed it
/// pays its owner crystals every [GameConfig.resourceNodePayoutInterval]
/// seconds.
///
/// Only the human player currently has a crystal wallet
/// (`GameStateRepository.crystals`), so an AI-owned node quietly holds
/// ownership without paying out anything yet - that's wired up once AI
/// opponents get their own economy.
class ResourceNodeComponent extends PositionComponent
    with HasGameReference<BoomspireGame> {
  Team? owner;

  Team? _leadingTeam;
  double _captureProgress = 0;
  double _payoutTimer = 0;

  late final CircleComponent _core;
  late final CircleComponent _progressRing;

  ResourceNodeComponent({required Vector2 position})
    : super(position: position, size: Vector2.all(36), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _progressRing = CircleComponent(
      radius: size.x / 2,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()..color = const Color(0x00000000),
    );
    _core = CircleComponent(
      radius: size.x / 2 - 6,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()..color = _ownerColor,
    );
    await addAll([_progressRing, _core]);
  }

  Color get _ownerColor => owner?.color ?? const Color(0xFF9E9E9E);

  @override
  void update(double dt) {
    super.update(dt);
    _updateCapture(dt);
    _updatePayout(dt);
    _core.paint.color = _ownerColor;
    _progressRing.paint.color = (_leadingTeam?.color ?? _ownerColor).withValues(
      alpha: _captureProgress / GameConfig.resourceNodeCaptureTime * 0.6,
    );
  }

  void _updateCapture(double dt) {
    final nearbyVehicleTeams = <Team>{};
    for (final unit in game.world.activeUnits) {
      if (unit.destroyed || !unit.blueprint.isVehicle) continue;
      if (unit.position.distanceTo(position) <=
          GameConfig.resourceNodeCaptureRadius) {
        nearbyVehicleTeams.add(unit.team);
      }
    }

    if (nearbyVehicleTeams.length != 1) {
      // Empty or contested: no progress is gained or lost either way.
      return;
    }

    final contender = nearbyVehicleTeams.first;
    if (contender == owner) {
      _captureProgress = 0;
      _leadingTeam = null;
      return;
    }

    if (contender != _leadingTeam) {
      _leadingTeam = contender;
      _captureProgress = 0;
    }

    _captureProgress += dt;
    if (_captureProgress >= GameConfig.resourceNodeCaptureTime) {
      owner = contender;
      _leadingTeam = null;
      _captureProgress = 0;
      _payoutTimer = 0;
    }
  }

  void _updatePayout(double dt) {
    if (owner == null) return;
    _payoutTimer += dt;
    if (_payoutTimer < GameConfig.resourceNodePayoutInterval) return;
    _payoutTimer -= GameConfig.resourceNodePayoutInterval;
    if (owner == game.playerTeam) {
      game.gameState.addCrystals(GameConfig.resourceNodeCrystalsPerTick);
    } else if (owner == game.aiTeam) {
      game.aiEconomy?.addGold(GameConfig.aiResourceNodeGoldPerTick);
    }
  }
}
