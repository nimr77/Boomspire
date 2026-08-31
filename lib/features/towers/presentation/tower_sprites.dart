import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import '../../../core/rendering/procedural_image.dart';
import '../domain/models/building_type.dart';
import '../domain/models/tower_type.dart';
import '../domain/models/unit_type.dart';
import 'util/paint_anti_air_turret.dart';
import 'util/paint_artillery_bunker_turret.dart';
import 'util/paint_cannon_turret.dart';
import 'util/paint_command_post_turret.dart';
import 'util/paint_default_base.dart';
import 'util/paint_gold_mine_turret.dart';
import 'util/paint_laser_turret.dart';
import 'util/paint_machine_gun_turret.dart';
import 'util/paint_power_plant_turret.dart';
import 'util/paint_rocket_silo_turret.dart';
import 'util/paint_rocket_turret.dart';
import 'util/paint_sam_turret.dart';
import 'util/paint_tech_lab_turret.dart';
import 'util/paint_training_center_base.dart';
import 'util/paint_training_center_turret.dart';
import 'util/paint_war_factory_base.dart';
import 'util/paint_war_factory_turret.dart';

/// Procedurally paints tower base plates and turrets - our "2D object
/// models" for towers and buildings, cached per [UnitType] so art is
/// generated once.
class TowerSpriteFactory {
  static final Map<UnitType, Sprite> _baseCache = {};

  static final Map<UnitType, Sprite> _turretCache = {};
  TowerSpriteFactory._();

  /// The faction color for this unit type - reused for turret art and for
  /// the ground fire-pulse effect when it shoots.
  static Color accentColor(UnitType type) => switch (type) {
    TowerType.rocket => const Color(0xFFFF6B35),
    TowerType.cannon => const Color(0xFFFFC107),
    TowerType.antiAir => const Color(0xFF7C4DFF),
    TowerType.machineGun => const Color(0xFF4FC3F7),
    TowerType.laser => const Color(0xFFFF3D9A),
    TowerType.rocketSilo => const Color(0xFFFF8A00),
    TowerType.artilleryBunker => const Color(0xFF8D6E63),
    TowerType.sam => const Color(0xFF00E5FF),
    BuildingType.techLab => const Color(0xFF1DE9B6),
    BuildingType.commandPost => const Color(0xFFFFD54A),
    BuildingType.trainingCenter => const Color(0xFF66BB6A),
    BuildingType.warFactory => const Color(0xFFB0BEC5),
    BuildingType.goldMine => const Color(0xFFFFB300),
    BuildingType.powerPlant => const Color(0xFF42A5F5),
    _ => const Color(0xFFBDBDBD),
  };

  static Future<Sprite> base(UnitType type) async {
    final cached = _baseCache[type];
    if (cached != null) return cached;
    final image = await renderToImage(64, 64, (c) => _paintBase(c, type));
    return _baseCache[type] = Sprite(image);
  }

  static Future<Sprite> turret(UnitType type) async {
    final cached = _turretCache[type];
    if (cached != null) return cached;
    final image = await renderToImage(48, 48, (c) => _paintTurret(c, type));
    return _turretCache[type] = Sprite(image);
  }

  static void _paintBase(Canvas canvas, UnitType type) {
    // Support buildings get a distinct building silhouette instead of the
    // round weapon-mount plate every combat tower shares.
    if (type == BuildingType.trainingCenter) {
      paintTrainingCenterBase(canvas);
      return;
    }
    if (type == BuildingType.warFactory) {
      paintWarFactoryBase(canvas);
      return;
    }
    paintDefaultBase(canvas, accentColor(type));
  }

  static void _paintTurret(Canvas canvas, UnitType type) {
    const center = Offset(24, 24);
    switch (type) {
      case TowerType.machineGun:
        paintMachineGunTurret(canvas, center);
      case TowerType.rocket:
        paintRocketTurret(canvas, center);
      case TowerType.cannon:
        paintCannonTurret(canvas, center);
      case TowerType.antiAir:
        paintAntiAirTurret(canvas, center);
      case TowerType.laser:
        paintLaserTurret(canvas, center);
      case TowerType.rocketSilo:
        paintRocketSiloTurret(canvas, center);
      case TowerType.artilleryBunker:
        paintArtilleryBunkerTurret(canvas, center);
      case TowerType.sam:
        paintSamTurret(canvas, center);
      case BuildingType.techLab:
        paintTechLabTurret(canvas, center);
      case BuildingType.commandPost:
        paintCommandPostTurret(canvas, center);
      case BuildingType.trainingCenter:
        paintTrainingCenterTurret(canvas, center);
      case BuildingType.warFactory:
        paintWarFactoryTurret(canvas, center);
      case BuildingType.goldMine:
        paintGoldMineTurret(canvas, center);
      case BuildingType.powerPlant:
        paintPowerPlantTurret(canvas, center);
    }
  }
}
