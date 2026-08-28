import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/combat/enums/movement_style.dart';
import '../../../../core/combat/enums/weapon_type.dart';
import '../../../../core/combat/unit.dart';
import '../enums/mobility_type.dart';
import 'asset_source.dart';
import 'build_requirement.dart';
import 'game_object_category.dart';
import 'sound_ref.dart';

export '../enums/mobility_type.dart';

part 'game_object_definition.freezed.dart';
part 'game_object_definition.g.dart';

/// Pure version comparison - no I/O, so it's trivial to unit test and to
/// reuse both for a single object and when diffing a whole manifest.
bool needsUpdate({
  required GameObjectDefinition cached,
  required GameObjectDefinition incoming,
}) => incoming.version > cached.version;

List<BuildRequirement> _requirementsFromJson(List<dynamic> json) => json
    .map((e) => BuildRequirement.fromJson(e as Map<String, dynamic>))
    .toList();

List<Map<String, dynamic>> _requirementsToJson(
  List<BuildRequirement> requirements,
) => requirements.map((r) => r.toJson()).toList();

/// Everything needed for one tower/building/unit to exist in the game -
/// combat stats, build gating, visuals, and sound - as a single versioned,
/// JSON-serializable record. Replaces the hardcoded `const` blueprint maps
/// in `TowerRepositoryImpl`/`BuildingRepositoryImpl`/`MobileUnitRepositoryImpl`:
/// the same shape is used for the bundled seed manifest (shipped as an
/// asset, so the game has content with zero network), the ToStore-cached
/// copy, and whatever the server returns.
///
/// [name] is deliberately NOT included here - user-facing text always comes
/// from `S.current.<key>` per the l10n rule, never from server data, so
/// [id] doubles as the lookup key into a small id-to-l10n-getter mapping
/// maintained on the client (see the catalog hydration step).
@freezed
abstract class GameObjectDefinition with _$GameObjectDefinition {
  const factory GameObjectDefinition({
    /// Stable key, e.g. `"tower.machineGun"`, `"building.techLab"`,
    /// `"unit.tank"` - `<category>.<enum name>` by convention.
    required String id,

    /// Bumped by the server whenever any field below changes; see
    /// [needsUpdate].
    required int version,
    required GameObjectCategory category,

    // --- Combat profile (towers/buildings use a subset; buildings leave
    // damage/fireRate/range at 0, matching today's UnitBlueprint usage).
    @Default(0) double damage,
    @Default(WeaponType.bullet) WeaponType weaponType,
    @Default(1) double fireRate,
    @Default(0) double range,
    @Default(0) double minRange,
    @Default(0) double splashRadius,
    @Default(0) double maxHp,
    @Default(UnitDomain.ground) UnitDomain domain,
    @Default({UnitDomain.ground}) Set<UnitDomain> attackDomains,
    @Default(0) int cost,

    // --- Mobile-unit-only fields (category == unit); ignored otherwise.
    @Default(0) double speed,
    @Default(0) double size,
    @Default(1) int projectileCount,
    @Default(MovementStyle.walk) MovementStyle movementStyle,
    @Default(MobilityType.infantry) MobilityType unitType,
    @Default(0) int bounty,
    @Default(false) bool prefersStructures,

    /// Buildings only: ids of [GameObjectDefinition]s (category == unit)
    /// this building can produce.
    @Default(<String>[]) List<String> producibleUnitIds,

    @JsonKey(fromJson: _requirementsFromJson, toJson: _requirementsToJson)
    @Default(<BuildRequirement>[])
    List<BuildRequirement> requirements,

    required AssetSource modelView,
    required SoundRef sound,
  }) = _GameObjectDefinition;

  factory GameObjectDefinition.fromJson(Map<String, dynamic> json) =>
      _$GameObjectDefinitionFromJson(json);
}
