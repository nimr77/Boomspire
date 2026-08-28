// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_object_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameObjectDefinition _$GameObjectDefinitionFromJson(
  Map<String, dynamic> json,
) => _GameObjectDefinition(
  id: json['id'] as String,
  version: (json['version'] as num).toInt(),
  category: $enumDecode(_$GameObjectCategoryEnumMap, json['category']),
  damage: (json['damage'] as num?)?.toDouble() ?? 0,
  weaponType:
      $enumDecodeNullable(_$WeaponTypeEnumMap, json['weaponType']) ??
      WeaponType.bullet,
  fireRate: (json['fireRate'] as num?)?.toDouble() ?? 1,
  range: (json['range'] as num?)?.toDouble() ?? 0,
  minRange: (json['minRange'] as num?)?.toDouble() ?? 0,
  splashRadius: (json['splashRadius'] as num?)?.toDouble() ?? 0,
  maxHp: (json['maxHp'] as num?)?.toDouble() ?? 0,
  domain:
      $enumDecodeNullable(_$UnitDomainEnumMap, json['domain']) ??
      UnitDomain.ground,
  attackDomains:
      (json['attackDomains'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$UnitDomainEnumMap, e))
          .toSet() ??
      const {UnitDomain.ground},
  cost: (json['cost'] as num?)?.toInt() ?? 0,
  speed: (json['speed'] as num?)?.toDouble() ?? 0,
  size: (json['size'] as num?)?.toDouble() ?? 0,
  projectileCount: (json['projectileCount'] as num?)?.toInt() ?? 1,
  movementStyle:
      $enumDecodeNullable(_$MovementStyleEnumMap, json['movementStyle']) ??
      MovementStyle.walk,
  isVehicle: json['isVehicle'] as bool? ?? false,
  bounty: (json['bounty'] as num?)?.toInt() ?? 0,
  prefersStructures: json['prefersStructures'] as bool? ?? false,
  producibleUnitIds:
      (json['producibleUnitIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  requirements: json['requirements'] == null
      ? const <BuildRequirement>[]
      : _requirementsFromJson(json['requirements'] as List),
  asset: AssetSource.fromJson(json['asset'] as Map<String, dynamic>),
  sound: SoundRef.fromJson(json['sound'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GameObjectDefinitionToJson(
  _GameObjectDefinition instance,
) => <String, dynamic>{
  'id': instance.id,
  'version': instance.version,
  'category': _$GameObjectCategoryEnumMap[instance.category]!,
  'damage': instance.damage,
  'weaponType': _$WeaponTypeEnumMap[instance.weaponType]!,
  'fireRate': instance.fireRate,
  'range': instance.range,
  'minRange': instance.minRange,
  'splashRadius': instance.splashRadius,
  'maxHp': instance.maxHp,
  'domain': _$UnitDomainEnumMap[instance.domain]!,
  'attackDomains': instance.attackDomains
      .map((e) => _$UnitDomainEnumMap[e]!)
      .toList(),
  'cost': instance.cost,
  'speed': instance.speed,
  'size': instance.size,
  'projectileCount': instance.projectileCount,
  'movementStyle': _$MovementStyleEnumMap[instance.movementStyle]!,
  'isVehicle': instance.isVehicle,
  'bounty': instance.bounty,
  'prefersStructures': instance.prefersStructures,
  'producibleUnitIds': instance.producibleUnitIds,
  'requirements': _requirementsToJson(instance.requirements),
  'asset': instance.asset.toJson(),
  'sound': instance.sound.toJson(),
};

const _$GameObjectCategoryEnumMap = {
  GameObjectCategory.tower: 'tower',
  GameObjectCategory.building: 'building',
  GameObjectCategory.unit: 'unit',
};

const _$WeaponTypeEnumMap = {
  WeaponType.bullet: 'bullet',
  WeaponType.cannon: 'cannon',
  WeaponType.rocket: 'rocket',
  WeaponType.laser: 'laser',
};

const _$UnitDomainEnumMap = {
  UnitDomain.ground: 'ground',
  UnitDomain.air: 'air',
  UnitDomain.sea: 'sea',
};

const _$MovementStyleEnumMap = {
  MovementStyle.walk: 'walk',
  MovementStyle.roll: 'roll',
  MovementStyle.hover: 'hover',
  MovementStyle.swoop: 'swoop',
  MovementStyle.sail: 'sail',
};
