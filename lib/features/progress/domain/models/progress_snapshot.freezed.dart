// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProgressSnapshot {

 Set<String> get completedSceneIds; Map<String, int> get bestWaveByScene; int get totalScore;
/// Create a copy of ProgressSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressSnapshotCopyWith<ProgressSnapshot> get copyWith => _$ProgressSnapshotCopyWithImpl<ProgressSnapshot>(this as ProgressSnapshot, _$identity);

  /// Serializes this ProgressSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressSnapshot&&const DeepCollectionEquality().equals(other.completedSceneIds, completedSceneIds)&&const DeepCollectionEquality().equals(other.bestWaveByScene, bestWaveByScene)&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(completedSceneIds),const DeepCollectionEquality().hash(bestWaveByScene),totalScore);

@override
String toString() {
  return 'ProgressSnapshot(completedSceneIds: $completedSceneIds, bestWaveByScene: $bestWaveByScene, totalScore: $totalScore)';
}


}

/// @nodoc
abstract mixin class $ProgressSnapshotCopyWith<$Res>  {
  factory $ProgressSnapshotCopyWith(ProgressSnapshot value, $Res Function(ProgressSnapshot) _then) = _$ProgressSnapshotCopyWithImpl;
@useResult
$Res call({
 Set<String> completedSceneIds, Map<String, int> bestWaveByScene, int totalScore
});




}
/// @nodoc
class _$ProgressSnapshotCopyWithImpl<$Res>
    implements $ProgressSnapshotCopyWith<$Res> {
  _$ProgressSnapshotCopyWithImpl(this._self, this._then);

  final ProgressSnapshot _self;
  final $Res Function(ProgressSnapshot) _then;

/// Create a copy of ProgressSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? completedSceneIds = null,Object? bestWaveByScene = null,Object? totalScore = null,}) {
  return _then(ProgressSnapshot(
completedSceneIds: null == completedSceneIds ? _self.completedSceneIds : completedSceneIds // ignore: cast_nullable_to_non_nullable
as Set<String>,bestWaveByScene: null == bestWaveByScene ? _self.bestWaveByScene : bestWaveByScene // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgressSnapshot].
extension ProgressSnapshotPatterns on ProgressSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgressSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgressSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgressSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _ProgressSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgressSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _ProgressSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<String> completedSceneIds,  Map<String, int> bestWaveByScene,  int totalScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgressSnapshot() when $default != null:
return $default(_that.completedSceneIds,_that.bestWaveByScene,_that.totalScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<String> completedSceneIds,  Map<String, int> bestWaveByScene,  int totalScore)  $default,) {final _that = this;
switch (_that) {
case _ProgressSnapshot():
return $default(_that.completedSceneIds,_that.bestWaveByScene,_that.totalScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<String> completedSceneIds,  Map<String, int> bestWaveByScene,  int totalScore)?  $default,) {final _that = this;
switch (_that) {
case _ProgressSnapshot() when $default != null:
return $default(_that.completedSceneIds,_that.bestWaveByScene,_that.totalScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProgressSnapshot extends ProgressSnapshot {
  const _ProgressSnapshot({ Set<String> completedSceneIds = const <String>{},  Map<String, int> bestWaveByScene = const <String, int>{}, this.totalScore = 0}): _completedSceneIds = completedSceneIds,_bestWaveByScene = bestWaveByScene,super._();
  factory _ProgressSnapshot.fromJson(Map<String, dynamic> json) => _$ProgressSnapshotFromJson(json);

 final  Set<String> _completedSceneIds;
@override@JsonKey() Set<String> get completedSceneIds {
  if (_completedSceneIds is EqualUnmodifiableSetView) return _completedSceneIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_completedSceneIds);
}

 final  Map<String, int> _bestWaveByScene;
@override@JsonKey() Map<String, int> get bestWaveByScene {
  if (_bestWaveByScene is EqualUnmodifiableMapView) return _bestWaveByScene;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bestWaveByScene);
}

@override@JsonKey() final  int totalScore;

/// Create a copy of ProgressSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressSnapshotCopyWith<_ProgressSnapshot> get copyWith => __$ProgressSnapshotCopyWithImpl<_ProgressSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProgressSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressSnapshot&&const DeepCollectionEquality().equals(other._completedSceneIds, _completedSceneIds)&&const DeepCollectionEquality().equals(other._bestWaveByScene, _bestWaveByScene)&&(identical(other.totalScore, totalScore) || other.totalScore == totalScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_completedSceneIds),const DeepCollectionEquality().hash(_bestWaveByScene),totalScore);

@override
String toString() {
  return 'ProgressSnapshot(completedSceneIds: $completedSceneIds, bestWaveByScene: $bestWaveByScene, totalScore: $totalScore)';
}


}

/// @nodoc
abstract mixin class _$ProgressSnapshotCopyWith<$Res> implements $ProgressSnapshotCopyWith<$Res> {
  factory _$ProgressSnapshotCopyWith(_ProgressSnapshot value, $Res Function(_ProgressSnapshot) _then) = __$ProgressSnapshotCopyWithImpl;
@override @useResult
$Res call({
 Set<String> completedSceneIds, Map<String, int> bestWaveByScene, int totalScore
});




}
/// @nodoc
class __$ProgressSnapshotCopyWithImpl<$Res>
    implements _$ProgressSnapshotCopyWith<$Res> {
  __$ProgressSnapshotCopyWithImpl(this._self, this._then);

  final _ProgressSnapshot _self;
  final $Res Function(_ProgressSnapshot) _then;

/// Create a copy of ProgressSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? completedSceneIds = null,Object? bestWaveByScene = null,Object? totalScore = null,}) {
  return _then(_ProgressSnapshot(
completedSceneIds: null == completedSceneIds ? _self._completedSceneIds : completedSceneIds // ignore: cast_nullable_to_non_nullable
as Set<String>,bestWaveByScene: null == bestWaveByScene ? _self._bestWaveByScene : bestWaveByScene // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalScore: null == totalScore ? _self.totalScore : totalScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
