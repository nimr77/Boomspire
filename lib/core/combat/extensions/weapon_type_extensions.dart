import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../enums/weapon_type.dart';

/// Display label + icon for a [WeaponType] - used anywhere a unit's attack
/// profile needs to be shown to the player (e.g. an entity info panel).
extension WeaponTypeExtensions on WeaponType {
  IconData get icon => switch (this) {
    WeaponType.bullet => Icons.track_changes,
    WeaponType.cannon => Icons.whatshot,
    WeaponType.rocket => Icons.rocket_launch,
    WeaponType.laser => Icons.bolt,
  };

  String get label => switch (this) {
    WeaponType.bullet => S.current.weaponLabelBullet,
    WeaponType.cannon => S.current.weaponLabelCannon,
    WeaponType.rocket => S.current.weaponLabelRocket,
    WeaponType.laser => S.current.weaponLabelLaser,
  };
}
