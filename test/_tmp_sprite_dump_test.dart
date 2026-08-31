import 'dart:io';
import 'dart:ui' as ui;

import 'package:boomspire/features/allies/presentation/components/ally_sprite_factory/ally_sprite_factory.dart';
import 'package:boomspire/features/enemies/presentation/components/enemy_sprite_factory/enemy_sprite_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dump enemy + ally sprites to /tmp for visual review', () async {
    await _dump(
      'enemy_soldier',
      () async => (await EnemySpriteFactory.soldier()).image,
    );
    await _dump(
      'enemy_heavy',
      () async => (await EnemySpriteFactory.heavySoldier()).image,
    );
    await _dump(
      'enemy_tank',
      () async => (await EnemySpriteFactory.tank()).image,
    );
    await _dump(
      'enemy_helicopter',
      () async => (await EnemySpriteFactory.helicopter()).image,
    );
    await _dump(
      'enemy_attackplane',
      () async => (await EnemySpriteFactory.attackPlane()).image,
    );
    await _dump(
      'enemy_artillery',
      () async => (await EnemySpriteFactory.artilleryBarrage()).image,
    );
    await _dump(
      'enemy_rocketbarrage',
      () async => (await EnemySpriteFactory.rocketBarrage()).image,
    );
    await _dump(
      'enemy_antiairvehicle',
      () async => (await EnemySpriteFactory.antiAirVehicle()).image,
    );

    await _dump(
      'ally_soldier',
      () async => (await AllySpriteFactory.soldier()).image,
    );
    await _dump(
      'ally_tank',
      () async => (await AllySpriteFactory.tank()).image,
    );
    await _dump(
      'ally_lightvehicle',
      () async => (await AllySpriteFactory.lightVehicle()).image,
    );
    await _dump(
      'ally_aircraft',
      () async => (await AllySpriteFactory.aircraft()).image,
    );
    await _dump(
      'ally_rocketbarrage',
      () async => (await AllySpriteFactory.rocketBarrage()).image,
    );
    await _dump(
      'ally_antitank',
      () async => (await AllySpriteFactory.antiTank()).image,
    );
    await _dump(
      'ally_antiair',
      () async => (await AllySpriteFactory.antiAir()).image,
    );
  });
}

Future<void> _dump(String name, Future<ui.Image> Function() build) async {
  final image = await build();
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File('/tmp/sprite_$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}
