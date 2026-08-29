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

 String get id; String get name; Biome get biome; GameMode get mode; double get arenaWidth; double get arenaHeight; List<PaintedCell> get paintedCells; List<TreeCell> get treeCells; List<WaterPath> get waterPaths; List<EditorPoint> get homeSites; EnvironmentSettings get environment; int get startingGold; int get waveCount; List<WaveLoadout> get waveLoadouts;
/// Create a copy of MapDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapDraftCopyWith<MapDraft> get copyWith => _$MapDraftCopyWithImpl<MapDraft>(this as MapDraft, _$identity);

  /// Serializes this MapDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.biome, biome) || other.biome == biome)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.arenaWidth, arenaWidth) || other.arenaWidth == arenaWidth)&&(identical(other.arenaHeight, arenaHeight) || other.arenaHeight == arenaHeight)&&const DeepCollectionEquality().equals(other.paintedCells, paintedCells)&&const DeepCollectionEquality().equals(other.treeCells, treeCells)&&const DeepCollectionEquality().equals(other.waterPaths, waterPaths)&&const DeepCollectionEquality().equals(other.homeSites, homeSites)&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.startingGold, startingGold) || other.startingGold == startingGold)&&(identical(other.waveCount, waveCount) || other.waveCount == waveCount)&&const DeepCollectionEquality().equals(other.waveLoadouts, waveLoadouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,biome,mode,arenaWidth,arenaHeight,const DeepCollectionEquality().hash(paintedCells),const DeepCollectionEquality().hash(treeCells),const DeepCollectionEquality().hash(waterPaths),const DeepCollectionEquality().hash(homeSites),environment,startingGold,waveCount,const DeepCollectionEquality().hash(waveLoadouts));

@override
String toString() {
  return 'MapDraft(id: $id, name: $name, biome: $biome, mode: $mode, arenaWidth: $arenaWidth, arenaHeight: $arenaHeight, paintedCells: $paintedCells, treeCells: $treeCells, waterPaths: $waterPaths, homeSites: $homeSites, environment: $environment, startingGold: $startingGold, waveCount: $waveCount, waveLoadouts: $waveLoadouts)';
}


}

/// @nodoc
abstract mixin class $MapDraftCopyWith<$Res>  {
  factory $MapDraftCopyWith(MapDraft value, $Res Function(MapDraft) _then) = _$MapDraftCopyWithImpl;
@useResult
$Res call({
 String id, String name, Biome biome, GameMode mode, double arenaWidth, double arenaHeight, List<PaintedCell> paintedCells, List<TreeCell> treeCells, List<WaterPath> waterPaths, List<EditorPoint> homeSites, EnvironmentSettings environment, int startingGold, int waveCount, List<WaveLoadout> waveLoadouts
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? biome = null,Object? mode = null,Object? arenaWidth = null,Object? arenaHeight = null,Object? paintedCells = null,Object? treeCells = null,Object? waterPaths = null,Object? homeSites = null,Object? environment = null,Object? startingGold = null,Object? waveCount = null,Object? waveLoadouts = null,}) {
  return _then(MapDraft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,biome: null == biome ? _self.biome : biome // ignore: cast_nullable_to_non_nullable
as Biome,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,arenaWidth: null == arenaWidth ? _self.arenaWidth : arenaWidth // ignore: cast_nullable_to_non_nullable
as double,arenaHeight: null == arenaHeight ? _self.arenaHeight : arenaHeight // ignore: cast_nullable_to_non_nullable
as double,paintedCells: null == paintedCells ? _self.paintedCells : paintedCells // ignore: cast_nullable_to_non_nullable
as List<PaintedCell>,treeCells: null == treeCells ? _self.treeCells : treeCells // ignore: cast_nullable_to_non_nullable
as List<TreeCell>,waterPaths: null == waterPaths ? _self.waterPaths : waterPaths // ignore: cast_nullable_to_non_nullable
as List<WaterPath>,homeSites: null == homeSites ? _self.homeSites : homeSites // ignore: cast_nullable_to_non_nullable
as List<EditorPoint>,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as EnvironmentSettings,startingGold: null == startingGold ? _self.startingGold : startingGold // ignore: cast_nullable_to_non_nullable
as int,waveCount: null == waveCount ? _self.waveCount : waveCount // ignore: cast_nullable_to_non_nullable
as int,waveLoadouts: null == waveLoadouts ? _self.waveLoadouts : waveLoadouts // ignore: cast_nullable_to_non_nullable
as List<WaveLoadout>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Biome biome,  GameMode mode,  double arenaWidth,  double arenaHeight,  List<PaintedCell> paintedCells,  List<TreeCell> treeCells,  List<WaterPath> waterPaths,  List<EditorPoint> homeSites,  EnvironmentSettings environment,  int startingGold,  int waveCount,  List<WaveLoadout> waveLoadouts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapDraft() when $default != null:
return $default(_that.id,_that.name,_that.biome,_that.mode,_that.arenaWidth,_that.arenaHeight,_that.paintedCells,_that.treeCells,_that.waterPaths,_that.homeSites,_that.environment,_that.startingGold,_that.waveCount,_that.waveLoadouts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Biome biome,  GameMode mode,  double arenaWidth,  double arenaHeight,  List<PaintedCell> paintedCells,  List<TreeCell> treeCells,  List<WaterPath> waterPaths,  List<EditorPoint> homeSites,  EnvironmentSettings environment,  int startingGold,  int waveCount,  List<WaveLoadout> waveLoadouts)  $default,) {final _that = this;
switch (_that) {
case _MapDraft():
return $default(_that.id,_that.name,_that.biome,_that.mode,_that.arenaWidth,_that.arenaHeight,_that.paintedCells,_that.treeCells,_that.waterPaths,_that.homeSites,_that.environment,_that.startingGold,_that.waveCount,_that.waveLoadouts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Biome biome,  GameMode mode,  double arenaWidth,  double arenaHeight,  List<PaintedCell> paintedCells,  List<TreeCell> treeCells,  List<WaterPath> waterPaths,  List<EditorPoint> homeSites,  EnvironmentSettings environment,  int startingGold,  int waveCount,  List<WaveLoadout> waveLoadouts)?  $default,) {final _that = this;
switch (_that) {
case _MapDraft() when $default != null:
return $default(_that.id,_that.name,_that.biome,_that.mode,_that.arenaWidth,_that.arenaHeight,_that.paintedCells,_that.treeCells,_that.waterPaths,_that.homeSites,_that.environment,_that.startingGold,_that.waveCount,_that.waveLoadouts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MapDraft implements MapDraft {
  const _MapDraft({required this.id, required this.name, this.biome = Biome.grassPlains, this.mode = GameMode.waveDefense, this.arenaWidth = 1280.0, this.arenaHeight = 720.0,  List<PaintedCell> paintedCells = const [],  List<TreeCell> treeCells = const [],  List<WaterPath> waterPaths = const [],  List<EditorPoint> homeSites = const [], this.environment = const EnvironmentSettings(), this.startingGold = 3000, this.waveCount = 10,  List<WaveLoadout> waveLoadouts = const []}): _paintedCells = paintedCells,_treeCells = treeCells,_waterPaths = waterPaths,_homeSites = homeSites,_waveLoadouts = waveLoadouts;
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

 final  List<TreeCell> _treeCells;
@override@JsonKey() List<TreeCell> get treeCells {
  if (_treeCells is EqualUnmodifiableListView) return _treeCells;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_treeCells);
}

 final  List<WaterPath> _waterPaths;
@override@JsonKey() List<WaterPath> get waterPaths {
  if (_waterPaths is EqualUnmodifiableListView) return _waterPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waterPaths);
}

 final  List<EditorPoint> _homeSites;
@override@JsonKey() List<EditorPoint> get homeSites {
  if (_homeSites is EqualUnmodifiableListView) return _homeSites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_homeSites);
}

@override@JsonKey() final  EnvironmentSettings environment;
@override@JsonKey() final  int startingGold;
@override@JsonKey() final  int waveCount;
 final  List<WaveLoadout> _waveLoadouts;
@override@JsonKey() List<WaveLoadout> get waveLoadouts {
  if (_waveLoadouts is EqualUnmodifiableListView) return _waveLoadouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waveLoadouts);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.biome, biome) || other.biome == biome)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.arenaWidth, arenaWidth) || other.arenaWidth == arenaWidth)&&(identical(other.arenaHeight, arenaHeight) || other.arenaHeight == arenaHeight)&&const DeepCollectionEquality().equals(other._paintedCells, _paintedCells)&&const DeepCollectionEquality().equals(other._treeCells, _treeCells)&&const DeepCollectionEquality().equals(other._waterPaths, _waterPaths)&&const DeepCollectionEquality().equals(other._homeSites, _homeSites)&&(identical(other.environment, environment) || other.environment == environment)&&(identical(other.startingGold, startingGold) || other.startingGold == startingGold)&&(identical(other.waveCount, waveCount) || other.waveCount == waveCount)&&const DeepCollectionEquality().equals(other._waveLoadouts, _waveLoadouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,biome,mode,arenaWidth,arenaHeight,const DeepCollectionEquality().hash(_paintedCells),const DeepCollectionEquality().hash(_treeCells),const DeepCollectionEquality().hash(_waterPaths),const DeepCollectionEquality().hash(_homeSites),environment,startingGold,waveCount,const DeepCollectionEquality().hash(_waveLoadouts));

@override
String toString() {
  return 'MapDraft(id: $id, name: $name, biome: $biome, mode: $mode, arenaWidth: $arenaWidth, arenaHeight: $arenaHeight, paintedCells: $paintedCells, treeCells: $treeCells, waterPaths: $waterPaths, homeSites: $homeSites, environment: $environment, startingGold: $startingGold, waveCount: $waveCount, waveLoadouts: $waveLoadouts)';
}


}

/// @nodoc
abstract mixin class _$MapDraftCopyWith<$Res> implements $MapDraftCopyWith<$Res> {
  factory _$MapDraftCopyWith(_MapDraft value, $Res Function(_MapDraft) _then) = __$MapDraftCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Biome biome, GameMode mode, double arenaWidth, double arenaHeight, List<PaintedCell> paintedCells, List<TreeCell> treeCells, List<WaterPath> waterPaths, List<EditorPoint> homeSites, EnvironmentSettings environment, int startingGold, int waveCount, List<WaveLoadout> waveLoadouts
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? biome = null,Object? mode = null,Object? arenaWidth = null,Object? arenaHeight = null,Object? paintedCells = null,Object? treeCells = null,Object? waterPaths = null,Object? homeSites = null,Object? environment = null,Object? startingGold = null,Object? waveCount = null,Object? waveLoadouts = null,}) {
  return _then(_MapDraft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,biome: null == biome ? _self.biome : biome // ignore: cast_nullable_to_non_nullable
as Biome,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,arenaWidth: null == arenaWidth ? _self.arenaWidth : arenaWidth // ignore: cast_nullable_to_non_nullable
as double,arenaHeight: null == arenaHeight ? _self.arenaHeight : arenaHeight // ignore: cast_nullable_to_non_nullable
as double,paintedCells: null == paintedCells ? _self._paintedCells : paintedCells // ignore: cast_nullable_to_non_nullable
as List<PaintedCell>,treeCells: null == treeCells ? _self._treeCells : treeCells // ignore: cast_nullable_to_non_nullable
as List<TreeCell>,waterPaths: null == waterPaths ? _self._waterPaths : waterPaths // ignore: cast_nullable_to_non_nullable
as List<WaterPath>,homeSites: null == homeSites ? _self._homeSites : homeSites // ignore: cast_nullable_to_non_nullable
as List<EditorPoint>,environment: null == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as EnvironmentSettings,startingGold: null == startingGold ? _self.startingGold : startingGold // ignore: cast_nullable_to_non_nullable
as int,waveCount: null == waveCount ? _self.waveCount : waveCount // ignore: cast_nullable_to_non_nullable
as int,waveLoadouts: null == waveLoadouts ? _self._waveLoadouts : waveLoadouts // ignore: cast_nullable_to_non_nullable
as List<WaveLoadout>,
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
