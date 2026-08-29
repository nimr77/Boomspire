// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_keyframe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeatherKeyframe {

/// How far through the match this keyframe applies, 0 (start) to 1 (end).
 double get atProgress; double get windStrength; double get rainIntensity; double get snowIntensity; double get fogDensity; double get cloudCover;/// [WindType.automatic] (the default) inherits the map's own biome's
/// natural wind look - see [resolvedWindType]. Any other value is an
/// explicit author override, editable in the map editor regardless of
/// [EnvironmentAdaptation] (that toggle only gates tree variants).
 WindType get windType;
/// Create a copy of WeatherKeyframe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherKeyframeCopyWith<WeatherKeyframe> get copyWith => _$WeatherKeyframeCopyWithImpl<WeatherKeyframe>(this as WeatherKeyframe, _$identity);

  /// Serializes this WeatherKeyframe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherKeyframe&&(identical(other.atProgress, atProgress) || other.atProgress == atProgress)&&(identical(other.windStrength, windStrength) || other.windStrength == windStrength)&&(identical(other.rainIntensity, rainIntensity) || other.rainIntensity == rainIntensity)&&(identical(other.snowIntensity, snowIntensity) || other.snowIntensity == snowIntensity)&&(identical(other.fogDensity, fogDensity) || other.fogDensity == fogDensity)&&(identical(other.cloudCover, cloudCover) || other.cloudCover == cloudCover)&&(identical(other.windType, windType) || other.windType == windType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,atProgress,windStrength,rainIntensity,snowIntensity,fogDensity,cloudCover,windType);

@override
String toString() {
  return 'WeatherKeyframe(atProgress: $atProgress, windStrength: $windStrength, rainIntensity: $rainIntensity, snowIntensity: $snowIntensity, fogDensity: $fogDensity, cloudCover: $cloudCover, windType: $windType)';
}


}

/// @nodoc
abstract mixin class $WeatherKeyframeCopyWith<$Res>  {
  factory $WeatherKeyframeCopyWith(WeatherKeyframe value, $Res Function(WeatherKeyframe) _then) = _$WeatherKeyframeCopyWithImpl;
@useResult
$Res call({
 double atProgress, double windStrength, double rainIntensity, double snowIntensity, double fogDensity, double cloudCover, WindType windType
});




}
/// @nodoc
class _$WeatherKeyframeCopyWithImpl<$Res>
    implements $WeatherKeyframeCopyWith<$Res> {
  _$WeatherKeyframeCopyWithImpl(this._self, this._then);

  final WeatherKeyframe _self;
  final $Res Function(WeatherKeyframe) _then;

/// Create a copy of WeatherKeyframe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? atProgress = null,Object? windStrength = null,Object? rainIntensity = null,Object? snowIntensity = null,Object? fogDensity = null,Object? cloudCover = null,Object? windType = null,}) {
  return _then(WeatherKeyframe(
atProgress: null == atProgress ? _self.atProgress : atProgress // ignore: cast_nullable_to_non_nullable
as double,windStrength: null == windStrength ? _self.windStrength : windStrength // ignore: cast_nullable_to_non_nullable
as double,rainIntensity: null == rainIntensity ? _self.rainIntensity : rainIntensity // ignore: cast_nullable_to_non_nullable
as double,snowIntensity: null == snowIntensity ? _self.snowIntensity : snowIntensity // ignore: cast_nullable_to_non_nullable
as double,fogDensity: null == fogDensity ? _self.fogDensity : fogDensity // ignore: cast_nullable_to_non_nullable
as double,cloudCover: null == cloudCover ? _self.cloudCover : cloudCover // ignore: cast_nullable_to_non_nullable
as double,windType: null == windType ? _self.windType : windType // ignore: cast_nullable_to_non_nullable
as WindType,
  ));
}

}


/// Adds pattern-matching-related methods to [WeatherKeyframe].
extension WeatherKeyframePatterns on WeatherKeyframe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeatherKeyframe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeatherKeyframe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeatherKeyframe value)  $default,){
final _that = this;
switch (_that) {
case _WeatherKeyframe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeatherKeyframe value)?  $default,){
final _that = this;
switch (_that) {
case _WeatherKeyframe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double atProgress,  double windStrength,  double rainIntensity,  double snowIntensity,  double fogDensity,  double cloudCover,  WindType windType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeatherKeyframe() when $default != null:
return $default(_that.atProgress,_that.windStrength,_that.rainIntensity,_that.snowIntensity,_that.fogDensity,_that.cloudCover,_that.windType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double atProgress,  double windStrength,  double rainIntensity,  double snowIntensity,  double fogDensity,  double cloudCover,  WindType windType)  $default,) {final _that = this;
switch (_that) {
case _WeatherKeyframe():
return $default(_that.atProgress,_that.windStrength,_that.rainIntensity,_that.snowIntensity,_that.fogDensity,_that.cloudCover,_that.windType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double atProgress,  double windStrength,  double rainIntensity,  double snowIntensity,  double fogDensity,  double cloudCover,  WindType windType)?  $default,) {final _that = this;
switch (_that) {
case _WeatherKeyframe() when $default != null:
return $default(_that.atProgress,_that.windStrength,_that.rainIntensity,_that.snowIntensity,_that.fogDensity,_that.cloudCover,_that.windType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeatherKeyframe extends WeatherKeyframe {
  const _WeatherKeyframe({required this.atProgress, this.windStrength = 0.0, this.rainIntensity = 0.0, this.snowIntensity = 0.0, this.fogDensity = 0.0, this.cloudCover = 0.0, this.windType = WindType.automatic}): super._();
  factory _WeatherKeyframe.fromJson(Map<String, dynamic> json) => _$WeatherKeyframeFromJson(json);

/// How far through the match this keyframe applies, 0 (start) to 1 (end).
@override final  double atProgress;
@override@JsonKey() final  double windStrength;
@override@JsonKey() final  double rainIntensity;
@override@JsonKey() final  double snowIntensity;
@override@JsonKey() final  double fogDensity;
@override@JsonKey() final  double cloudCover;
/// [WindType.automatic] (the default) inherits the map's own biome's
/// natural wind look - see [resolvedWindType]. Any other value is an
/// explicit author override, editable in the map editor regardless of
/// [EnvironmentAdaptation] (that toggle only gates tree variants).
@override@JsonKey() final  WindType windType;

/// Create a copy of WeatherKeyframe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherKeyframeCopyWith<_WeatherKeyframe> get copyWith => __$WeatherKeyframeCopyWithImpl<_WeatherKeyframe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeatherKeyframeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherKeyframe&&(identical(other.atProgress, atProgress) || other.atProgress == atProgress)&&(identical(other.windStrength, windStrength) || other.windStrength == windStrength)&&(identical(other.rainIntensity, rainIntensity) || other.rainIntensity == rainIntensity)&&(identical(other.snowIntensity, snowIntensity) || other.snowIntensity == snowIntensity)&&(identical(other.fogDensity, fogDensity) || other.fogDensity == fogDensity)&&(identical(other.cloudCover, cloudCover) || other.cloudCover == cloudCover)&&(identical(other.windType, windType) || other.windType == windType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,atProgress,windStrength,rainIntensity,snowIntensity,fogDensity,cloudCover,windType);

@override
String toString() {
  return 'WeatherKeyframe(atProgress: $atProgress, windStrength: $windStrength, rainIntensity: $rainIntensity, snowIntensity: $snowIntensity, fogDensity: $fogDensity, cloudCover: $cloudCover, windType: $windType)';
}


}

/// @nodoc
abstract mixin class _$WeatherKeyframeCopyWith<$Res> implements $WeatherKeyframeCopyWith<$Res> {
  factory _$WeatherKeyframeCopyWith(_WeatherKeyframe value, $Res Function(_WeatherKeyframe) _then) = __$WeatherKeyframeCopyWithImpl;
@override @useResult
$Res call({
 double atProgress, double windStrength, double rainIntensity, double snowIntensity, double fogDensity, double cloudCover, WindType windType
});




}
/// @nodoc
class __$WeatherKeyframeCopyWithImpl<$Res>
    implements _$WeatherKeyframeCopyWith<$Res> {
  __$WeatherKeyframeCopyWithImpl(this._self, this._then);

  final _WeatherKeyframe _self;
  final $Res Function(_WeatherKeyframe) _then;

/// Create a copy of WeatherKeyframe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? atProgress = null,Object? windStrength = null,Object? rainIntensity = null,Object? snowIntensity = null,Object? fogDensity = null,Object? cloudCover = null,Object? windType = null,}) {
  return _then(_WeatherKeyframe(
atProgress: null == atProgress ? _self.atProgress : atProgress // ignore: cast_nullable_to_non_nullable
as double,windStrength: null == windStrength ? _self.windStrength : windStrength // ignore: cast_nullable_to_non_nullable
as double,rainIntensity: null == rainIntensity ? _self.rainIntensity : rainIntensity // ignore: cast_nullable_to_non_nullable
as double,snowIntensity: null == snowIntensity ? _self.snowIntensity : snowIntensity // ignore: cast_nullable_to_non_nullable
as double,fogDensity: null == fogDensity ? _self.fogDensity : fogDensity // ignore: cast_nullable_to_non_nullable
as double,cloudCover: null == cloudCover ? _self.cloudCover : cloudCover // ignore: cast_nullable_to_non_nullable
as double,windType: null == windType ? _self.windType : windType // ignore: cast_nullable_to_non_nullable
as WindType,
  ));
}


}

// dart format on
