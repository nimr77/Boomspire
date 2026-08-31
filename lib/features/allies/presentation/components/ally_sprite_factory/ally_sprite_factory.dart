import 'package:flame/sprite.dart';

import '../../../../../core/combat/unit_kind.dart';
import '../../../../../core/rendering/procedural_image.dart';
import 'util/paint_aircraft.dart';
import 'util/paint_anti_air.dart';
import 'util/paint_anti_tank.dart';
import 'util/paint_drone.dart';
import 'util/paint_light_vehicle.dart';
import 'util/paint_rocket_barrage.dart';
import 'util/paint_soldier.dart';
import 'util/paint_stealth_bomber.dart';
import 'util/paint_tank.dart';

/// Procedurally paints the friendly unit "2D object models" - soldier, tank,
/// light vehicle and aircraft - all sharing the home base's cyan livery
/// (see `kHomeAccentColor`) so they read as "ours" at a glance, cached
/// after first generation.
class AllySpriteFactory {
  static Sprite? _soldier;
  static Sprite? _tank;
  static Sprite? _lightVehicle;
  static Sprite? _aircraft;
  static Sprite? _rocketBarrage;
  static Sprite? _antiTank;
  static Sprite? _antiAir;
  static Sprite? _stealthBomber;
  static Sprite? _drone;
  AllySpriteFactory._();

  static Future<Sprite> aircraft() async {
    final cached = _aircraft;
    if (cached != null) return cached;
    final image = await renderToImage(50, 50, paintAircraft);
    return _aircraft = Sprite(image);
  }

  static Future<Sprite> antiAir() async {
    final cached = _antiAir;
    if (cached != null) return cached;
    final image = await renderToImage(48, 48, paintAntiAir);
    return _antiAir = Sprite(image);
  }

  static Future<Sprite> antiTank() async {
    final cached = _antiTank;
    if (cached != null) return cached;
    final image = await renderToImage(48, 48, paintAntiTank);
    return _antiTank = Sprite(image);
  }

  static Future<Sprite> drone() async {
    final cached = _drone;
    if (cached != null) return cached;
    final image = await renderToImage(42, 42, paintDrone);
    return _drone = Sprite(image);
  }

  static Future<Sprite> lightVehicle() async {
    final cached = _lightVehicle;
    if (cached != null) return cached;
    final image = await renderToImage(46, 46, paintLightVehicle);
    return _lightVehicle = Sprite(image);
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
    final image = await renderToImage(48, 48, paintSoldier);
    return _soldier = Sprite(image);
  }

  static Future<Sprite> spriteFor(UnitKind kind) => switch (kind) {
    UnitKind.soldier => soldier(),
    UnitKind.tank => tank(),
    UnitKind.lightVehicle => lightVehicle(),
    UnitKind.aircraft => aircraft(),
    UnitKind.rocketBarrage => rocketBarrage(),
    UnitKind.antiTankSoldier => antiTank(),
    UnitKind.antiAirSoldier => antiAir(),
    UnitKind.stealthBomber => stealthBomber(),
    UnitKind.drone => drone(),
    _ => throw ArgumentError('No ally sprite for $kind'),
  };

  static Future<Sprite> stealthBomber() async {
    final cached = _stealthBomber;
    if (cached != null) return cached;
    final image = await renderToImage(54, 54, paintStealthBomber);
    return _stealthBomber = Sprite(image);
  }

  /// Every [UnitKind] this factory has art for - lets a merged unit
  /// component fall back to the other side's factory for a kind that was
  /// only ever painted for one side (e.g. an invader-only Attack Plane).
  static bool supports(UnitKind kind) => switch (kind) {
    UnitKind.soldier ||
    UnitKind.tank ||
    UnitKind.lightVehicle ||
    UnitKind.aircraft ||
    UnitKind.rocketBarrage ||
    UnitKind.antiTankSoldier ||
    UnitKind.antiAirSoldier ||
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
