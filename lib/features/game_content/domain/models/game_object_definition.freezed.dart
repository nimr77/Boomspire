// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_object_definition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameObjectDefinition {

/// Stable key, e.g. `"tower.machineGun"`, `"building.techLab"`,
/// `"unit.tank"` - `<category>.<enum name>` by convention.
 String get id;/// Bumped by the server whenever any field below changes; see
/// [needsUpdate].
 int get version; GameObjectCategory get category; double get damage; WeaponType get weaponType; double get fireRate; double get range; double get minRange; double get splashRadius; double get maxHp; UnitDomain get domain; Set<UnitDomain> get attackDomains; int get cost; double get speed; double get size; int get projectileCount; MovementStyle get movementStyle; bool get isVehicle; int get bounty; bool get prefersStructures;/// Buildings only: ids of [GameObjectDefinition]s (category == unit)
/// this building can produce.
 List<String> get producibleUnitIds;@JsonKey(fromJson: _requirementsFromJson, toJson: _requirementsToJson) List<BuildRequirement> get requirements; AssetSource get asset; SoundRef get sound;
/// Create a copy of GameObjectDefinition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameObjectDefinitionCopyWith<GameObjectDefinition> get copyWith => _$GameObjectDefinitionCopyWithImpl<GameObjectDefinition>(this as GameObjectDefinition, _$identity);

  /// Serializes this GameObjectDefinition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameObjectDefinition&&(identical(other.id, id) || other.id == id)&&(identical(other.version, version) || other.version == version)&&(identical(other.category, category) || other.category == category)&&(identical(other.damage, damage) || other.damage == damage)&&(identical(other.weaponType, weaponType) || other.weaponType == weaponType)&&(identical(other.fireRate, fireRate) || other.fireRate == fireRate)&&(identical(other.range, range) || other.range == range)&&(identical(other.minRange, minRange) || other.minRange == minRange)&&(identical(other.splashRadius, splashRadius) || other.splashRadius == splashRadius)&&(identical(other.maxHp, maxHp) || other.maxHp == maxHp)&&(identical(other.domain, domain) || other.domain == domain)&&const DeepCollectionEquality().equals(other.attackDomains, attackDomains)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.size, size) || other.size == size)&&(identical(other.projectileCount, projectileCount) || other.projectileCount == projectileCount)&&(identical(other.movementStyle, movementStyle) || other.movementStyle == movementStyle)&&(identical(other.isVehicle, isVehicle) || other.isVehicle == isVehicle)&&(identical(other.bounty, bounty) || other.bounty == bounty)&&(identical(other.prefersStructures, prefersStructures) || other.prefersStructures == prefersStructures)&&const DeepCollectionEquality().equals(other.producibleUnitIds, producibleUnitIds)&&const DeepCollectionEquality().equals(other.requirements, requirements)&&(identical(other.asset, asset) || other.asset == asset)&&(identical(other.sound, sound) || other.sound == sound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,version,category,damage,weaponType,fireRate,range,minRange,splashRadius,maxHp,domain,const DeepCollectionEquality().hash(attackDomains),cost,speed,size,projectileCount,movementStyle,isVehicle,bounty,prefersStructures,const DeepCollectionEquality().hash(producibleUnitIds),const DeepCollectionEquality().hash(requirements),asset,sound]);

@override
String toString() {
  return 'GameObjectDefinition(id: $id, version: $version, category: $category, damage: $damage, weaponType: $weaponType, fireRate: $fireRate, range: $range, minRange: $minRange, splashRadius: $splashRadius, maxHp: $maxHp, domain: $domain, attackDomains: $attackDomains, cost: $cost, speed: $speed, size: $size, projectileCount: $projectileCount, movementStyle: $movementStyle, isVehicle: $isVehicle, bounty: $bounty, prefersStructures: $prefersStructures, producibleUnitIds: $producibleUnitIds, requirements: $requirements, asset: $asset, sound: $sound)';
}


}

/// @nodoc
abstract mixin class $GameObjectDefinitionCopyWith<$Res>  {
  factory $GameObjectDefinitionCopyWith(GameObjectDefinition value, $Res Function(GameObjectDefinition) _then) = _$GameObjectDefinitionCopyWithImpl;
@useResult
$Res call({
 String id, int version, GameObjectCategory category, double damage, WeaponType weaponType, double fireRate, double range, double minRange, double splashRadius, double maxHp, UnitDomain domain, Set<UnitDomain> attackDomains, int cost, double speed, double size, int projectileCount, MovementStyle movementStyle, bool isVehicle, int bounty, bool prefersStructures, List<String> producibleUnitIds,@JsonKey(fromJson: _requirementsFromJson, toJson: _requirementsToJson) List<BuildRequirement> requirements, AssetSource asset, SoundRef sound
});


$AssetSourceCopyWith<$Res> get asset;$SoundRefCopyWith<$Res> get sound;

}
/// @nodoc
class _$GameObjectDefinitionCopyWithImpl<$Res>
    implements $GameObjectDefinitionCopyWith<$Res> {
  _$GameObjectDefinitionCopyWithImpl(this._self, this._then);

  final GameObjectDefinition _self;
  final $Res Function(GameObjectDefinition) _then;

/// Create a copy of GameObjectDefinition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? version = null,Object? category = null,Object? damage = null,Object? weaponType = null,Object? fireRate = null,Object? range = null,Object? minRange = null,Object? splashRadius = null,Object? maxHp = null,Object? domain = null,Object? attackDomains = null,Object? cost = null,Object? speed = null,Object? size = null,Object? projectileCount = null,Object? movementStyle = null,Object? isVehicle = null,Object? bounty = null,Object? prefersStructures = null,Object? producibleUnitIds = null,Object? requirements = null,Object? asset = null,Object? sound = null,}) {
  return _then(GameObjectDefinition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as GameObjectCategory,damage: null == damage ? _self.damage : damage // ignore: cast_nullable_to_non_nullable
as double,weaponType: null == weaponType ? _self.weaponType : weaponType // ignore: cast_nullable_to_non_nullable
as WeaponType,fireRate: null == fireRate ? _self.fireRate : fireRate // ignore: cast_nullable_to_non_nullable
as double,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as double,minRange: null == minRange ? _self.minRange : minRange // ignore: cast_nullable_to_non_nullable
as double,splashRadius: null == splashRadius ? _self.splashRadius : splashRadius // ignore: cast_nullable_to_non_nullable
as double,maxHp: null == maxHp ? _self.maxHp : maxHp // ignore: cast_nullable_to_non_nullable
as double,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as UnitDomain,attackDomains: null == attackDomains ? _self.attackDomains : attackDomains // ignore: cast_nullable_to_non_nullable
as Set<UnitDomain>,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as double,projectileCount: null == projectileCount ? _self.projectileCount : projectileCount // ignore: cast_nullable_to_non_nullable
as int,movementStyle: null == movementStyle ? _self.movementStyle : movementStyle // ignore: cast_nullable_to_non_nullable
as MovementStyle,isVehicle: null == isVehicle ? _self.isVehicle : isVehicle // ignore: cast_nullable_to_non_nullable
as bool,bounty: null == bounty ? _self.bounty : bounty // ignore: cast_nullable_to_non_nullable
as int,prefersStructures: null == prefersStructures ? _self.prefersStructures : prefersStructures // ignore: cast_nullable_to_non_nullable
as bool,producibleUnitIds: null == producibleUnitIds ? _self.producibleUnitIds : producibleUnitIds // ignore: cast_nullable_to_non_nullable
as List<String>,requirements: null == requirements ? _self.requirements : requirements // ignore: cast_nullable_to_non_nullable
as List<BuildRequirement>,asset: null == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as AssetSource,sound: null == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as SoundRef,
  ));
}
/// Create a copy of GameObjectDefinition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssetSourceCopyWith<$Res> get asset {
  
  return $AssetSourceCopyWith<$Res>(_self.asset, (value) {
    return _then(_self.copyWith(asset: value));
  });
}/// Create a copy of GameObjectDefinition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoundRefCopyWith<$Res> get sound {
  
  return $SoundRefCopyWith<$Res>(_self.sound, (value) {
    return _then(_self.copyWith(sound: value));
  });
}
}


/// Adds pattern-matching-related methods to [GameObjectDefinition].
extension GameObjectDefinitionPatterns on GameObjectDefinition {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameObjectDefinition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameObjectDefinition() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameObjectDefinition value)  $default,){
final _that = this;
switch (_that) {
case _GameObjectDefinition():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameObjectDefinition value)?  $default,){
final _that = this;
switch (_that) {
case _GameObjectDefinition() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int version,  GameObjectCategory category,  double damage,  WeaponType weaponType,  double fireRate,  double range,  double minRange,  double splashRadius,  double maxHp,  UnitDomain domain,  Set<UnitDomain> attackDomains,  int cost,  double speed,  double size,  int projectileCount,  MovementStyle movementStyle,  bool isVehicle,  int bounty,  bool prefersStructures,  List<String> producibleUnitIds, @JsonKey(fromJson: _requirementsFromJson, toJson: _requirementsToJson)  List<BuildRequirement> requirements,  AssetSource asset,  SoundRef sound)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameObjectDefinition() when $default != null:
return $default(_that.id,_that.version,_that.category,_that.damage,_that.weaponType,_that.fireRate,_that.range,_that.minRange,_that.splashRadius,_that.maxHp,_that.domain,_that.attackDomains,_that.cost,_that.speed,_that.size,_that.projectileCount,_that.movementStyle,_that.isVehicle,_that.bounty,_that.prefersStructures,_that.producibleUnitIds,_that.requirements,_that.asset,_that.sound);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int version,  GameObjectCategory category,  double damage,  WeaponType weaponType,  double fireRate,  double range,  double minRange,  double splashRadius,  double maxHp,  UnitDomain domain,  Set<UnitDomain> attackDomains,  int cost,  double speed,  double size,  int projectileCount,  MovementStyle movementStyle,  bool isVehicle,  int bounty,  bool prefersStructures,  List<String> producibleUnitIds, @JsonKey(fromJson: _requirementsFromJson, toJson: _requirementsToJson)  List<BuildRequirement> requirements,  AssetSource asset,  SoundRef sound)  $default,) {final _that = this;
switch (_that) {
case _GameObjectDefinition():
return $default(_that.id,_that.version,_that.category,_that.damage,_that.weaponType,_that.fireRate,_that.range,_that.minRange,_that.splashRadius,_that.maxHp,_that.domain,_that.attackDomains,_that.cost,_that.speed,_that.size,_that.projectileCount,_that.movementStyle,_that.isVehicle,_that.bounty,_that.prefersStructures,_that.producibleUnitIds,_that.requirements,_that.asset,_that.sound);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int version,  GameObjectCategory category,  double damage,  WeaponType weaponType,  double fireRate,  double range,  double minRange,  double splashRadius,  double maxHp,  UnitDomain domain,  Set<UnitDomain> attackDomains,  int cost,  double speed,  double size,  int projectileCount,  MovementStyle movementStyle,  bool isVehicle,  int bounty,  bool prefersStructures,  List<String> producibleUnitIds, @JsonKey(fromJson: _requirementsFromJson, toJson: _requirementsToJson)  List<BuildRequirement> requirements,  AssetSource asset,  SoundRef sound)?  $default,) {final _that = this;
switch (_that) {
case _GameObjectDefinition() when $default != null:
return $default(_that.id,_that.version,_that.category,_that.damage,_that.weaponType,_that.fireRate,_that.range,_that.minRange,_that.splashRadius,_that.maxHp,_that.domain,_that.attackDomains,_that.cost,_that.speed,_that.size,_that.projectileCount,_that.movementStyle,_that.isVehicle,_that.bounty,_that.prefersStructures,_that.producibleUnitIds,_that.requirements,_that.asset,_that.sound);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameObjectDefinition implements GameObjectDefinition {
  const _GameObjectDefinition({required this.id, required this.version, required this.category, this.damage = 0, this.weaponType = WeaponType.bullet, this.fireRate = 1, this.range = 0, this.minRange = 0, this.splashRadius = 0, this.maxHp = 0, this.domain = UnitDomain.ground,  Set<UnitDomain> attackDomains = const {UnitDomain.ground}, this.cost = 0, this.speed = 0, this.size = 0, this.projectileCount = 1, this.movementStyle = MovementStyle.walk, this.isVehicle = false, this.bounty = 0, this.prefersStructures = false,  List<String> producibleUnitIds = const <String>[], @JsonKey(fromJson: _requirementsFromJson, toJson: _requirementsToJson)  List<BuildRequirement> requirements = const <BuildRequirement>[], required this.asset, required this.sound}): _attackDomains = attackDomains,_producibleUnitIds = producibleUnitIds,_requirements = requirements;
  factory _GameObjectDefinition.fromJson(Map<String, dynamic> json) => _$GameObjectDefinitionFromJson(json);

/// Stable key, e.g. `"tower.machineGun"`, `"building.techLab"`,
/// `"unit.tank"` - `<category>.<enum name>` by convention.
@override final  String id;
/// Bumped by the server whenever any field below changes; see
/// [needsUpdate].
@override final  int version;
@override final  GameObjectCategory category;
@override@JsonKey() final  double damage;
@override@JsonKey() final  WeaponType weaponType;
@override@JsonKey() final  double fireRate;
@override@JsonKey() final  double range;
@override@JsonKey() final  double minRange;
@override@JsonKey() final  double splashRadius;
@override@JsonKey() final  double maxHp;
@override@JsonKey() final  UnitDomain domain;
 final  Set<UnitDomain> _attackDomains;
@override@JsonKey() Set<UnitDomain> get attackDomains {
  if (_attackDomains is EqualUnmodifiableSetView) return _attackDomains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_attackDomains);
}

@override@JsonKey() final  int cost;
@override@JsonKey() final  double speed;
@override@JsonKey() final  double size;
@override@JsonKey() final  int projectileCount;
@override@JsonKey() final  MovementStyle movementStyle;
@override@JsonKey() final  bool isVehicle;
@override@JsonKey() final  int bounty;
@override@JsonKey() final  bool prefersStructures;
/// Buildings only: ids of [GameObjectDefinition]s (category == unit)
/// this building can produce.
 final  List<String> _producibleUnitIds;
/// Buildings only: ids of [GameObjectDefinition]s (category == unit)
/// this building can produce.
@override@JsonKey() List<String> get producibleUnitIds {
  if (_producibleUnitIds is EqualUnmodifiableListView) return _producibleUnitIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_producibleUnitIds);
}

 final  List<BuildRequirement> _requirements;
@override@JsonKey(fromJson: _requirementsFromJson, toJson: _requirementsToJson) List<BuildRequirement> get requirements {
  if (_requirements is EqualUnmodifiableListView) return _requirements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requirements);
}

@override final  AssetSource asset;
@override final  SoundRef sound;

/// Create a copy of GameObjectDefinition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameObjectDefinitionCopyWith<_GameObjectDefinition> get copyWith => __$GameObjectDefinitionCopyWithImpl<_GameObjectDefinition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameObjectDefinitionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameObjectDefinition&&(identical(other.id, id) || other.id == id)&&(identical(other.version, version) || other.version == version)&&(identical(other.category, category) || other.category == category)&&(identical(other.damage, damage) || other.damage == damage)&&(identical(other.weaponType, weaponType) || other.weaponType == weaponType)&&(identical(other.fireRate, fireRate) || other.fireRate == fireRate)&&(identical(other.range, range) || other.range == range)&&(identical(other.minRange, minRange) || other.minRange == minRange)&&(identical(other.splashRadius, splashRadius) || other.splashRadius == splashRadius)&&(identical(other.maxHp, maxHp) || other.maxHp == maxHp)&&(identical(other.domain, domain) || other.domain == domain)&&const DeepCollectionEquality().equals(other._attackDomains, _attackDomains)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.size, size) || other.size == size)&&(identical(other.projectileCount, projectileCount) || other.projectileCount == projectileCount)&&(identical(other.movementStyle, movementStyle) || other.movementStyle == movementStyle)&&(identical(other.isVehicle, isVehicle) || other.isVehicle == isVehicle)&&(identical(other.bounty, bounty) || other.bounty == bounty)&&(identical(other.prefersStructures, prefersStructures) || other.prefersStructures == prefersStructures)&&const DeepCollectionEquality().equals(other._producibleUnitIds, _producibleUnitIds)&&const DeepCollectionEquality().equals(other._requirements, _requirements)&&(identical(other.asset, asset) || other.asset == asset)&&(identical(other.sound, sound) || other.sound == sound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,version,category,damage,weaponType,fireRate,range,minRange,splashRadius,maxHp,domain,const DeepCollectionEquality().hash(_attackDomains),cost,speed,size,projectileCount,movementStyle,isVehicle,bounty,prefersStructures,const DeepCollectionEquality().hash(_producibleUnitIds),const DeepCollectionEquality().hash(_requirements),asset,sound]);

@override
String toString() {
  return 'GameObjectDefinition(id: $id, version: $version, category: $category, damage: $damage, weaponType: $weaponType, fireRate: $fireRate, range: $range, minRange: $minRange, splashRadius: $splashRadius, maxHp: $maxHp, domain: $domain, attackDomains: $attackDomains, cost: $cost, speed: $speed, size: $size, projectileCount: $projectileCount, movementStyle: $movementStyle, isVehicle: $isVehicle, bounty: $bounty, prefersStructures: $prefersStructures, producibleUnitIds: $producibleUnitIds, requirements: $requirements, asset: $asset, sound: $sound)';
}


}

/// @nodoc
abstract mixin class _$GameObjectDefinitionCopyWith<$Res> implements $GameObjectDefinitionCopyWith<$Res> {
  factory _$GameObjectDefinitionCopyWith(_GameObjectDefinition value, $Res Function(_GameObjectDefinition) _then) = __$GameObjectDefinitionCopyWithImpl;
@override @useResult
$Res call({
 String id, int version, GameObjectCategory category, double damage, WeaponType weaponType, double fireRate, double range, double minRange, double splashRadius, double maxHp, UnitDomain domain, Set<UnitDomain> attackDomains, int cost, double speed, double size, int projectileCount, MovementStyle movementStyle, bool isVehicle, int bounty, bool prefersStructures, List<String> producibleUnitIds,@JsonKey(fromJson: _requirementsFromJson, toJson: _requirementsToJson) List<BuildRequirement> requirements, AssetSource asset, SoundRef sound
});


@override $AssetSourceCopyWith<$Res> get asset;@override $SoundRefCopyWith<$Res> get sound;

}
/// @nodoc
class __$GameObjectDefinitionCopyWithImpl<$Res>
    implements _$GameObjectDefinitionCopyWith<$Res> {
  __$GameObjectDefinitionCopyWithImpl(this._self, this._then);

  final _GameObjectDefinition _self;
  final $Res Function(_GameObjectDefinition) _then;

/// Create a copy of GameObjectDefinition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? version = null,Object? category = null,Object? damage = null,Object? weaponType = null,Object? fireRate = null,Object? range = null,Object? minRange = null,Object? splashRadius = null,Object? maxHp = null,Object? domain = null,Object? attackDomains = null,Object? cost = null,Object? speed = null,Object? size = null,Object? projectileCount = null,Object? movementStyle = null,Object? isVehicle = null,Object? bounty = null,Object? prefersStructures = null,Object? producibleUnitIds = null,Object? requirements = null,Object? asset = null,Object? sound = null,}) {
  return _then(_GameObjectDefinition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as GameObjectCategory,damage: null == damage ? _self.damage : damage // ignore: cast_nullable_to_non_nullable
as double,weaponType: null == weaponType ? _self.weaponType : weaponType // ignore: cast_nullable_to_non_nullable
as WeaponType,fireRate: null == fireRate ? _self.fireRate : fireRate // ignore: cast_nullable_to_non_nullable
as double,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as double,minRange: null == minRange ? _self.minRange : minRange // ignore: cast_nullable_to_non_nullable
as double,splashRadius: null == splashRadius ? _self.splashRadius : splashRadius // ignore: cast_nullable_to_non_nullable
as double,maxHp: null == maxHp ? _self.maxHp : maxHp // ignore: cast_nullable_to_non_nullable
as double,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as UnitDomain,attackDomains: null == attackDomains ? _self._attackDomains : attackDomains // ignore: cast_nullable_to_non_nullable
as Set<UnitDomain>,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as double,projectileCount: null == projectileCount ? _self.projectileCount : projectileCount // ignore: cast_nullable_to_non_nullable
as int,movementStyle: null == movementStyle ? _self.movementStyle : movementStyle // ignore: cast_nullable_to_non_nullable
as MovementStyle,isVehicle: null == isVehicle ? _self.isVehicle : isVehicle // ignore: cast_nullable_to_non_nullable
as bool,bounty: null == bounty ? _self.bounty : bounty // ignore: cast_nullable_to_non_nullable
as int,prefersStructures: null == prefersStructures ? _self.prefersStructures : prefersStructures // ignore: cast_nullable_to_non_nullable
as bool,producibleUnitIds: null == producibleUnitIds ? _self._producibleUnitIds : producibleUnitIds // ignore: cast_nullable_to_non_nullable
as List<String>,requirements: null == requirements ? _self._requirements : requirements // ignore: cast_nullable_to_non_nullable
as List<BuildRequirement>,asset: null == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as AssetSource,sound: null == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as SoundRef,
  ));
}

/// Create a copy of GameObjectDefinition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssetSourceCopyWith<$Res> get asset {
  
  return $AssetSourceCopyWith<$Res>(_self.asset, (value) {
    return _then(_self.copyWith(asset: value));
  });
}/// Create a copy of GameObjectDefinition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoundRefCopyWith<$Res> get sound {
  
  return $SoundRefCopyWith<$Res>(_self.sound, (value) {
    return _then(_self.copyWith(sound: value));
  });
}
}

// dart format on
