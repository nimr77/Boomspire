// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MapDraft {

 String get id; String get name; Biome get biome; GameMode get mode; double get arenaWidth; double get arenaHeight; List<PaintedCell> get paintedCells; List<WaterPath> get waterPaths; EnvironmentSettings get environment;
/// Create a copy of MapDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapDraftCopyWith<MapDraft> get copyWith => _$MapDraftCopyWithImpl<MapDraft>(this as MapDraft, _$identity);

  /// Serializes this MapDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.biome, biome) || other.biome == biome)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.arenaWidth, arenaWidth) || other.arenaWidth == arenaWidth)&&(identical(other.arenaHeight, arenaHeight) || other.arenaHeight == arenaHeight)&&const DeepCollectionEquality().equals(other.paintedCells, paintedCells)&&const DeepCollectionEquality().equals(other.waterPaths, waterPaths)&&(identical(other.environment, environment) || other.environment == environment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,biome,mode,arenaWidth,arenaHeight,const DeepCollectionEquality().hash(paintedCells),const DeepCollectionEquality().hash(waterPaths),environment);

@override
String toString() {
  return 'MapDraft(id: $id, name: $name, biome: $biome, mode: $mode, arenaWidth: $arenaWidth, arenaHeight: $arenaHeight, paintedCells: $paintedCells, waterPaths: $waterPaths, environment: $environment)';
}


}

/// @nodoc
abstract mixin class $MapDraftCopyWith<$Res>  {
  factory $MapDraftCopyWith(MapDraft value, $Res Function(MapDraft) _then) = _$MapDraftCopyWithImpl;
@useResult
$Res call({
 String id, String name, Biome biome, GameMode mode, double arenaWidth, double arenaHeight, List<PaintedCell> paintedCells, List<WaterPath> waterPaths, EnvironmentSettings environment
});


$EnvironmentSettingsCopyWith<$Res> get environment;

}
/// @nodoc
class _$MapDraftCopyWithImpl<$Res>
    implements $MapDraftCopyWith<$Res> {
  _$MapDraftCopyWithImpl(this._self, this._then);

  final MapDraft _self;
  final $Res Function(MapDraft) _then;

/// Create a copy of MapDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? biome = null,Object? mode = null,Object? arenaWidth = null,Object? arenaHeight = null,Object? paintedCells = null,Object? waterPaths = null,Object? environment = null,}) {
  return _then(MapDraft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,biome: null == biome ? _self.biome : biome // ignore: cast_nullable_to_non_nullable
as Biome,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,arenaWidth: null == arenaWidth ? _self.arenaWidth : arenaWidth // ignore: cast_nullable_to_non_nullable
as double,arenaHeight: null == arenaHeight ? _self.arenaHeight : arenaHeight // ignore: cast_nullable_to_non_nullable
as double,paintedCells: null == paintedCells ? _self.paintedCells : paintedCells // ignore: cast_nullable_to_non_nullable
as List<PaintedCell>,waterPaths: null == waterPaths ? _self.waterPaths : waterPaths // ignore: cast_nullable_to_non_nullable
as List<WaterPath>,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as EnvironmentSettings,
  ));
}
/// Create a copy of MapDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnvironmentSettingsCopyWith<$Res> get environment {
  
  return $EnvironmentSettingsCopyWith<$Res>(_self.environment, (value) {
    return _then(_self.copyWith(environment: value));
  });
}
}


/// Adds pattern-matching-related methods to [MapDraft].
extension MapDraftPatterns on MapDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapDraft value)  $default,){
final _that = this;
switch (_that) {
case _MapDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapDraft value)?  $default,){
final _that = this;
switch (_that) {
case _MapDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Biome biome,  GameMode mode,  double arenaWidth,  double arenaHeight,  List<PaintedCell> paintedCells,  List<WaterPath> waterPaths,  EnvironmentSettings environment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapDraft() when $default != null:
return $default(_that.id,_that.name,_that.biome,_that.mode,_that.arenaWidth,_that.arenaHeight,_that.paintedCells,_that.waterPaths,_that.environment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Biome biome,  GameMode mode,  double arenaWidth,  double arenaHeight,  List<PaintedCell> paintedCells,  List<WaterPath> waterPaths,  EnvironmentSettings environment)  $default,) {final _that = this;
switch (_that) {
case _MapDraft():
return $default(_that.id,_that.name,_that.biome,_that.mode,_that.arenaWidth,_that.arenaHeight,_that.paintedCells,_that.waterPaths,_that.environment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Biome biome,  GameMode mode,  double arenaWidth,  double arenaHeight,  List<PaintedCell> paintedCells,  List<WaterPath> waterPaths,  EnvironmentSettings environment)?  $default,) {final _that = this;
switch (_that) {
case _MapDraft() when $default != null:
return $default(_that.id,_that.name,_that.biome,_that.mode,_that.arenaWidth,_that.arenaHeight,_that.paintedCells,_that.waterPaths,_that.environment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MapDraft implements MapDraft {
  const _MapDraft({required this.id, required this.name, this.biome = Biome.grassPlains, this.mode = GameMode.waveDefense, this.arenaWidth = 1280.0, this.arenaHeight = 720.0,  List<PaintedCell> paintedCells = const [],  List<WaterPath> waterPaths = const [], this.environment = const EnvironmentSettings()}): _paintedCells = paintedCells,_waterPaths = waterPaths;
  factory _MapDraft.fromJson(Map<String, dynamic> json) => _$MapDraftFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  Biome biome;
@override@JsonKey() final  GameMode mode;
@override@JsonKey() final  double arenaWidth;
@override@JsonKey() final  double arenaHeight;
 final  List<PaintedCell> _paintedCells;
@override@JsonKey() List<PaintedCell> get paintedCells {
  if (_paintedCells is EqualUnmodifiableListView) return _paintedCells;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paintedCells);
}

 final  List<WaterPath> _waterPaths;
@override@JsonKey() List<WaterPath> get waterPaths {
  if (_waterPaths is EqualUnmodifiableListView) return _waterPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waterPaths);
}

@override@JsonKey() final  EnvironmentSettings environment;

/// Create a copy of MapDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapDraftCopyWith<_MapDraft> get copyWith => __$MapDraftCopyWithImpl<_MapDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MapDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.biome, biome) || other.biome == biome)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.arenaWidth, arenaWidth) || other.arenaWidth == arenaWidth)&&(identical(other.arenaHeight, arenaHeight) || other.arenaHeight == arenaHeight)&&const DeepCollectionEquality().equals(other._paintedCells, _paintedCells)&&const DeepCollectionEquality().equals(other._waterPaths, _waterPaths)&&(identical(other.environment, environment) || other.environment == environment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,biome,mode,arenaWidth,arenaHeight,const DeepCollectionEquality().hash(_paintedCells),const DeepCollectionEquality().hash(_waterPaths),environment);

@override
String toString() {
  return 'MapDraft(id: $id, name: $name, biome: $biome, mode: $mode, arenaWidth: $arenaWidth, arenaHeight: $arenaHeight, paintedCells: $paintedCells, waterPaths: $waterPaths, environment: $environment)';
}


}

/// @nodoc
abstract mixin class _$MapDraftCopyWith<$Res> implements $MapDraftCopyWith<$Res> {
  factory _$MapDraftCopyWith(_MapDraft value, $Res Function(_MapDraft) _then) = __$MapDraftCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Biome biome, GameMode mode, double arenaWidth, double arenaHeight, List<PaintedCell> paintedCells, List<WaterPath> waterPaths, EnvironmentSettings environment
});


@override $EnvironmentSettingsCopyWith<$Res> get environment;

}
/// @nodoc
class __$MapDraftCopyWithImpl<$Res>
    implements _$MapDraftCopyWith<$Res> {
  __$MapDraftCopyWithImpl(this._self, this._then);

  final _MapDraft _self;
  final $Res Function(_MapDraft) _then;

/// Create a copy of MapDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? biome = null,Object? mode = null,Object? arenaWidth = null,Object? arenaHeight = null,Object? paintedCells = null,Object? waterPaths = null,Object? environment = null,}) {
  return _then(_MapDraft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,biome: null == biome ? _self.biome : biome // ignore: cast_nullable_to_non_nullable
as Biome,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,arenaWidth: null == arenaWidth ? _self.arenaWidth : arenaWidth // ignore: cast_nullable_to_non_nullable
as double,arenaHeight: null == arenaHeight ? _self.arenaHeight : arenaHeight // ignore: cast_nullable_to_non_nullable
as double,paintedCells: null == paintedCells ? _self._paintedCells : paintedCells // ignore: cast_nullable_to_non_nullable
as List<PaintedCell>,waterPaths: null == waterPaths ? _self._waterPaths : waterPaths // ignore: cast_nullable_to_non_nullable
as List<WaterPath>,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as EnvironmentSettings,
  ));
}

/// Create a copy of MapDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnvironmentSettingsCopyWith<$Res> get environment {
  
  return $EnvironmentSettingsCopyWith<$Res>(_self.environment, (value) {
    return _then(_self.copyWith(environment: value));
  });
}
}

// dart format on
