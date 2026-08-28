import '../../../core/combat/enums/unit_catalog.dart';
import '../../../core/combat/mobile_unit_blueprint.dart';
import '../../towers/domain/models/building_type.dart';
import '../../towers/domain/models/tower_type.dart';
import '../../towers/domain/models/unit_blueprint.dart';
import '../domain/models/asset_source.dart';
import '../domain/models/build_requirement.dart';
import '../domain/models/game_object_category.dart';
import '../domain/models/game_object_definition.dart';
import '../domain/models/sound_ref.dart';

UnitBlueprint applyBuildingOverride(
  UnitBlueprint base,
  GameObjectDefinition override,
) => UnitBlueprint(
  type: base.type,
  name: base.name,
  cost: override.cost,
  range: override.range,
  minRange: override.minRange,
  damage: override.damage,
  fireRate: override.fireRate,
  splashRadius: override.splashRadius,
  maxHp: override.maxHp,
  domain: override.domain,
  attackDomains: override.attackDomains,
);

MobileUnitBlueprint applyMobileUnitOverride(
  MobileUnitBlueprint base,
  GameObjectDefinition override,
) => MobileUnitBlueprint(
  kind: base.kind,
  name: base.name,
  maxHealth: override.maxHp,
  speed: override.speed,
  size: override.size,
  domain: override.domain,
  attackDomains: override.attackDomains,
  attackDamage: override.damage,
  attackRange: override.range,
  attackInterval: override.fireRate,
  projectileCount: override.projectileCount,
  movementStyle: override.movementStyle,
  isVehicle: override.isVehicle,
  weaponType: override.weaponType,
  bounty: override.bounty,
  cost: override.cost,
  prefersStructures: override.prefersStructures,
);

/// Returns [base] with combat/cost stats replaced by [override]'s - `name`/
/// `type` always come from [base] since the manifest never carries
/// user-facing text (see the l10n rule).
UnitBlueprint applyTowerOverride(
  UnitBlueprint base,
  GameObjectDefinition override,
) => UnitBlueprint(
  type: base.type,
  name: base.name,
  cost: override.cost,
  range: override.range,
  minRange: override.minRange,
  damage: override.damage,
  fireRate: override.fireRate,
  splashRadius: override.splashRadius,
  maxHp: override.maxHp,
  domain: override.domain,
  attackDomains: override.attackDomains,
);

String buildingDefinitionId(BuildingType type) => 'building.${type.name}';

GameObjectDefinition buildingToDefinition(
  UnitBlueprint blueprint, {
  int version = 1,
  List<BuildRequirement> requirements = const [],
  List<String> producibleUnitIds = const [],
}) {
  final type = blueprint.type as BuildingType;
  return GameObjectDefinition(
    id: buildingDefinitionId(type),
    version: version,
    category: GameObjectCategory.building,
    maxHp: blueprint.maxHp,
    cost: blueprint.cost,
    requirements: requirements,
    producibleUnitIds: producibleUnitIds,
    asset: AssetSource(modelKey: 'building_${type.name}'),
    sound: const SoundRef(),
  );
}

/// Finds the synced definition (if any) whose id matches [id] among
/// [overrides] - repos call this to layer live/cached server data on top of
/// their own hardcoded fallback stats, so an empty/missing [overrides] list
/// (the default everywhere - no sync has happened, e.g. every existing
/// test) reproduces today's behavior exactly.
GameObjectDefinition? findOverride(
  List<GameObjectDefinition> overrides,
  String id,
) {
  for (final def in overrides) {
    if (def.id == id) return def;
  }
  return null;
}

GameObjectDefinition mobileUnitToDefinition(
  MobileUnitBlueprint blueprint,
  UnitCatalog catalog, {
  int version = 1,
  List<BuildRequirement> requirements = const [],
}) {
  return GameObjectDefinition(
    id: unitDefinitionId(catalog, blueprint.kind.name),
    version: version,
    category: GameObjectCategory.unit,
    damage: blueprint.attackDamage,
    weaponType: blueprint.weaponType,
    fireRate: blueprint.attackInterval,
    range: blueprint.attackRange,
    maxHp: blueprint.maxHealth,
    domain: blueprint.domain,
    attackDomains: blueprint.attackDomains,
    cost: blueprint.cost,
    speed: blueprint.speed,
    size: blueprint.size,
    projectileCount: blueprint.projectileCount,
    movementStyle: blueprint.movementStyle,
    isVehicle: blueprint.isVehicle,
    bounty: blueprint.bounty,
    prefersStructures: blueprint.prefersStructures,
    requirements: requirements,
    asset: AssetSource(modelKey: 'unit_${blueprint.kind.name}'),
    sound: const SoundRef(),
  );
}

/// `<category>.<enum name>` id for a tower/building (units get a
/// catalog-qualified id instead - see [unitDefinitionId] - since the same
/// `UnitKind` has different stats per `UnitCatalog` side).
String towerDefinitionId(TowerType type) => 'tower.${type.name}';

/// Converts an existing [UnitBlueprint] (as returned by
/// `TowerRepositoryImpl`) into the versioned, JSON-serializable shape used
/// by the sync/cache pipeline - a bridge so today's hand-tuned Dart
/// constants can seed the manifest without being hand-retyped as JSON.
GameObjectDefinition towerToDefinition(
  UnitBlueprint blueprint, {
  int version = 1,
  List<BuildRequirement> requirements = const [],
}) {
  final type = blueprint.type as TowerType;
  return GameObjectDefinition(
    id: towerDefinitionId(type),
    version: version,
    category: GameObjectCategory.tower,
    damage: blueprint.damage,
    fireRate: blueprint.fireRate,
    range: blueprint.range,
    minRange: blueprint.minRange,
    splashRadius: blueprint.splashRadius,
    maxHp: blueprint.maxHp,
    domain: blueprint.domain,
    attackDomains: blueprint.attackDomains,
    cost: blueprint.cost,
    requirements: requirements,
    asset: AssetSource(modelKey: 'tower_${type.name}'),
    sound: const SoundRef(),
  );
}

String unitDefinitionId(UnitCatalog catalog, String kindName) =>
    switch (catalog) {
      UnitCatalog.invaderRoster => 'unit.invader.$kindName',
      UnitCatalog.buildableRoster => 'unit.buildable.$kindName',
    };
