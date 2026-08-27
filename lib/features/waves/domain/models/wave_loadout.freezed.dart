// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wave_loadout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WaveLoadout {

 int get waveNumber; Map<String, int> get unitCounts;
/// Create a copy of WaveLoadout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaveLoadoutCopyWith<WaveLoadout> get copyWith => _$WaveLoadoutCopyWithImpl<WaveLoadout>(this as WaveLoadout, _$identity);

  /// Serializes this WaveLoadout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WaveLoadout&&(identical(other.waveNumber, waveNumber) || other.waveNumber == waveNumber)&&const DeepCollectionEquality().equals(other.unitCounts, unitCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,waveNumber,const DeepCollectionEquality().hash(unitCounts));

@override
String toString() {
  return 'WaveLoadout(waveNumber: $waveNumber, unitCounts: $unitCounts)';
}


}

/// @nodoc
abstract mixin class $WaveLoadoutCopyWith<$Res>  {
  factory $WaveLoadoutCopyWith(WaveLoadout value, $Res Function(WaveLoadout) _then) = _$WaveLoadoutCopyWithImpl;
@useResult
$Res call({
 int waveNumber, Map<String, int> unitCounts
});




}
/// @nodoc
class _$WaveLoadoutCopyWithImpl<$Res>
    implements $WaveLoadoutCopyWith<$Res> {
  _$WaveLoadoutCopyWithImpl(this._self, this._then);

  final WaveLoadout _self;
  final $Res Function(WaveLoadout) _then;

/// Create a copy of WaveLoadout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? waveNumber = null,Object? unitCounts = null,}) {
  return _then(WaveLoadout(
waveNumber: null == waveNumber ? _self.waveNumber : waveNumber // ignore: cast_nullable_to_non_nullable
as int,unitCounts: null == unitCounts ? _self.unitCounts : unitCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [WaveLoadout].
extension WaveLoadoutPatterns on WaveLoadout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WaveLoadout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WaveLoadout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WaveLoadout value)  $default,){
final _that = this;
switch (_that) {
case _WaveLoadout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WaveLoadout value)?  $default,){
final _that = this;
switch (_that) {
case _WaveLoadout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int waveNumber,  Map<String, int> unitCounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WaveLoadout() when $default != null:
return $default(_that.waveNumber,_that.unitCounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int waveNumber,  Map<String, int> unitCounts)  $default,) {final _that = this;
switch (_that) {
case _WaveLoadout():
return $default(_that.waveNumber,_that.unitCounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int waveNumber,  Map<String, int> unitCounts)?  $default,) {final _that = this;
switch (_that) {
case _WaveLoadout() when $default != null:
return $default(_that.waveNumber,_that.unitCounts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WaveLoadout extends WaveLoadout {
  const _WaveLoadout({required this.waveNumber,  Map<String, int> unitCounts = const <String, int>{}}): _unitCounts = unitCounts,super._();
  factory _WaveLoadout.fromJson(Map<String, dynamic> json) => _$WaveLoadoutFromJson(json);

@override final  int waveNumber;
 final  Map<String, int> _unitCounts;
@override@JsonKey() Map<String, int> get unitCounts {
  if (_unitCounts is EqualUnmodifiableMapView) return _unitCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_unitCounts);
}


/// Create a copy of WaveLoadout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WaveLoadoutCopyWith<_WaveLoadout> get copyWith => __$WaveLoadoutCopyWithImpl<_WaveLoadout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WaveLoadoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WaveLoadout&&(identical(other.waveNumber, waveNumber) || other.waveNumber == waveNumber)&&const DeepCollectionEquality().equals(other._unitCounts, _unitCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,waveNumber,const DeepCollectionEquality().hash(_unitCounts));

@override
String toString() {
  return 'WaveLoadout(waveNumber: $waveNumber, unitCounts: $unitCounts)';
}


}

/// @nodoc
abstract mixin class _$WaveLoadoutCopyWith<$Res> implements $WaveLoadoutCopyWith<$Res> {
  factory _$WaveLoadoutCopyWith(_WaveLoadout value, $Res Function(_WaveLoadout) _then) = __$WaveLoadoutCopyWithImpl;
@override @useResult
$Res call({
 int waveNumber, Map<String, int> unitCounts
});




}
/// @nodoc
class __$WaveLoadoutCopyWithImpl<$Res>
    implements _$WaveLoadoutCopyWith<$Res> {
  __$WaveLoadoutCopyWithImpl(this._self, this._then);

  final _WaveLoadout _self;
  final $Res Function(_WaveLoadout) _then;

/// Create a copy of WaveLoadout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? waveNumber = null,Object? unitCounts = null,}) {
  return _then(_WaveLoadout(
waveNumber: null == waveNumber ? _self.waveNumber : waveNumber // ignore: cast_nullable_to_non_nullable
as int,unitCounts: null == unitCounts ? _self._unitCounts : unitCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
