import 'package:flame/sprite.dart';

import '../../../../../core/combat/unit_kind.dart';
import '../../../../../core/rendering/procedural_image.dart';
import 'util/paint_anti_air_vehicle.dart';
import 'util/paint_artillery_barrage.dart';
import 'util/paint_attack_plane.dart';
import 'util/paint_drone.dart';
import 'util/paint_enemy_soldier.dart';
import 'util/paint_helicopter.dart';
import 'util/paint_rocket_barrage.dart';
import 'util/paint_stealth_bomber.dart';
import 'util/paint_tank.dart';

/// Procedurally paints the green-soldier "2D object models" - a regular
/// soldier and a bulkier, red-trimmed heavy soldier - cached after first
/// generation.
class EnemySpriteFactory {
  static Sprite? _soldier;

  static Sprite? _heavy;
  static Sprite? _helicopter;
  static Sprite? _tank;
  static Sprite? _attackPlane;
  static Sprite? _artilleryBarrage;
  static Sprite? _rocketBarrage;
  static Sprite? _antiAirVehicle;
  static Sprite? _stealthBomber;
  static Sprite? _drone;
  EnemySpriteFactory._();

  static Future<Sprite> antiAirVehicle() async {
    final cached = _antiAirVehicle;
    if (cached != null) return cached;
    final image = await renderToImage(52, 52, paintAntiAirVehicle);
    return _antiAirVehicle = Sprite(image);
  }

  static Future<Sprite> artilleryBarrage() async {
    final cached = _artilleryBarrage;
    if (cached != null) return cached;
    final image = await renderToImage(52, 52, paintArtilleryBarrage);
    return _artilleryBarrage = Sprite(image);
  }

  static Future<Sprite> attackPlane() async {
    final cached = _attackPlane;
    if (cached != null) return cached;
    final image = await renderToImage(50, 50, paintAttackPlane);
    return _attackPlane = Sprite(image);
  }

  static Future<Sprite> drone() async {
    final cached = _drone;
    if (cached != null) return cached;
    final image = await renderToImage(42, 42, paintDrone);
    return _drone = Sprite(image);
  }

  static Future<Sprite> heavySoldier() async {
    final cached = _heavy;
    if (cached != null) return cached;
    final image = await renderToImage(
      60,
      60,
      (c) => paintEnemySoldier(c, heavy: true),
    );
    return _heavy = Sprite(image);
  }

  static Future<Sprite> helicopter() async {
    final cached = _helicopter;
    if (cached != null) return cached;
    final image = await renderToImage(46, 46, paintHelicopter);
    return _helicopter = Sprite(image);
  }

  static Future<Sprite> rocketBarrage() async {
    final cached = _rocketBarrage;
    if (cached != null) return cached;
    final image = await renderToImage(50, 50, paintRocketBarrage);
    return _rocketBarrage = Sprite(image);
  }

  static Future<Sprite> soldier() async {
    final cached = _soldier;
    if (cached != null) return cached;
    final image = await renderToImage(
      48,
      48,
      (c) => paintEnemySoldier(c, heavy: false),
    );
    return _soldier = Sprite(image);
  }

  static Future<Sprite> spriteFor(UnitKind kind) => switch (kind) {
    UnitKind.soldier => soldier(),
    UnitKind.heavySoldier => heavySoldier(),
    UnitKind.tank => tank(),
    UnitKind.helicopter => helicopter(),
    UnitKind.attackPlane => attackPlane(),
    UnitKind.artilleryBarrage => artilleryBarrage(),
    UnitKind.rocketBarrage => rocketBarrage(),
    UnitKind.antiAirVehicle => antiAirVehicle(),
    UnitKind.stealthBomber => stealthBomber(),
    UnitKind.drone => drone(),
    _ => throw ArgumentError('No enemy sprite for $kind'),
  };

  static Future<Sprite> stealthBomber() async {
    final cached = _stealthBomber;
    if (cached != null) return cached;
    final image = await renderToImage(54, 54, paintStealthBomber);
    return _stealthBomber = Sprite(image);
  }

  /// Every [UnitKind] this factory has art for - lets a merged unit
  /// component fall back to the other side's factory for a kind that was
  /// only ever painted for one side (e.g. a player-built Helicopter).
  static bool supports(UnitKind kind) => switch (kind) {
    UnitKind.soldier ||
    UnitKind.heavySoldier ||
    UnitKind.tank ||
    UnitKind.helicopter ||
    UnitKind.attackPlane ||
    UnitKind.artilleryBarrage ||
    UnitKind.rocketBarrage ||
    UnitKind.antiAirVehicle ||
    UnitKind.stealthBomber ||
    UnitKind.drone => true,
    _ => false,
  };

  static Future<Sprite> tank() async {
    final cached = _tank;
    if (cached != null) return cached;
    final image = await renderToImage(54, 54, paintTank);
    return _tank = Sprite(image);
  }
}
