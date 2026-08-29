// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'environment_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EnvironmentSettings {

 bool get dynamicWeather;/// Sun direction as a fraction of a full arc, 0..1 (0 = sunrise/east,
/// 0.5 = overhead, 1 = sunset/west) - drives ambient light tint/shadow
/// angle wherever that's rendered.
 double get sunAngle; List<WeatherKeyframe> get timeline;/// [EnvironmentAdaptation.automatic] (default) keeps every terrain
/// object (trees) matching this map's own biome.
/// [EnvironmentAdaptation.manual] lets an author mix tree styles
/// instead - e.g. snow-dusted trees on a desert map. Wind type is a
/// separate, always-editable per-keyframe override - see
/// `WeatherKeyframe.resolvedWindType`.
 EnvironmentAdaptation get adaptation;
/// Create a copy of EnvironmentSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnvironmentSettingsCopyWith<EnvironmentSettings> get copyWith => _$EnvironmentSettingsCopyWithImpl<EnvironmentSettings>(this as EnvironmentSettings, _$identity);

  /// Serializes this EnvironmentSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvironmentSettings&&(identical(other.dynamicWeather, dynamicWeather) || other.dynamicWeather == dynamicWeather)&&(identical(other.sunAngle, sunAngle) || other.sunAngle == sunAngle)&&const DeepCollectionEquality().equals(other.timeline, timeline)&&(identical(other.adaptation, adaptation) || other.adaptation == adaptation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dynamicWeather,sunAngle,const DeepCollectionEquality().hash(timeline),adaptation);

@override
String toString() {
  return 'EnvironmentSettings(dynamicWeather: $dynamicWeather, sunAngle: $sunAngle, timeline: $timeline, adaptation: $adaptation)';
}


}

/// @nodoc
abstract mixin class $EnvironmentSettingsCopyWith<$Res>  {
  factory $EnvironmentSettingsCopyWith(EnvironmentSettings value, $Res Function(EnvironmentSettings) _then) = _$EnvironmentSettingsCopyWithImpl;
@useResult
$Res call({
 bool dynamicWeather, double sunAngle, List<WeatherKeyframe> timeline, EnvironmentAdaptation adaptation
});




}
/// @nodoc
class _$EnvironmentSettingsCopyWithImpl<$Res>
    implements $EnvironmentSettingsCopyWith<$Res> {
  _$EnvironmentSettingsCopyWithImpl(this._self, this._then);

  final EnvironmentSettings _self;
  final $Res Function(EnvironmentSettings) _then;

/// Create a copy of EnvironmentSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dynamicWeather = null,Object? sunAngle = null,Object? timeline = null,Object? adaptation = null,}) {
  return _then(EnvironmentSettings(
dynamicWeather: null == dynamicWeather ? _self.dynamicWeather : dynamicWeather // ignore: cast_nullable_to_non_nullable
as bool,sunAngle: null == sunAngle ? _self.sunAngle : sunAngle // ignore: cast_nullable_to_non_nullable
as double,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<WeatherKeyframe>,adaptation: null == adaptation ? _self.adaptation : adaptation // ignore: cast_nullable_to_non_nullable
as EnvironmentAdaptation,
  ));
}

}


/// Adds pattern-matching-related methods to [EnvironmentSettings].
extension EnvironmentSettingsPatterns on EnvironmentSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnvironmentSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnvironmentSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnvironmentSettings value)  $default,){
final _that = this;
switch (_that) {
case _EnvironmentSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnvironmentSettings value)?  $default,){
final _that = this;
switch (_that) {
case _EnvironmentSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool dynamicWeather,  double sunAngle,  List<WeatherKeyframe> timeline,  EnvironmentAdaptation adaptation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnvironmentSettings() when $default != null:
return $default(_that.dynamicWeather,_that.sunAngle,_that.timeline,_that.adaptation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool dynamicWeather,  double sunAngle,  List<WeatherKeyframe> timeline,  EnvironmentAdaptation adaptation)  $default,) {final _that = this;
switch (_that) {
case _EnvironmentSettings():
return $default(_that.dynamicWeather,_that.sunAngle,_that.timeline,_that.adaptation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool dynamicWeather,  double sunAngle,  List<WeatherKeyframe> timeline,  EnvironmentAdaptation adaptation)?  $default,) {final _that = this;
switch (_that) {
case _EnvironmentSettings() when $default != null:
return $default(_that.dynamicWeather,_that.sunAngle,_that.timeline,_that.adaptation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnvironmentSettings extends EnvironmentSettings {
  const _EnvironmentSettings({this.dynamicWeather = true, this.sunAngle = 0.5,  List<WeatherKeyframe> timeline = const [_defaultKeyframe], this.adaptation = EnvironmentAdaptation.automatic}): _timeline = timeline,super._();
  factory _EnvironmentSettings.fromJson(Map<String, dynamic> json) => _$EnvironmentSettingsFromJson(json);

@override@JsonKey() final  bool dynamicWeather;
/// Sun direction as a fraction of a full arc, 0..1 (0 = sunrise/east,
/// 0.5 = overhead, 1 = sunset/west) - drives ambient light tint/shadow
/// angle wherever that's rendered.
@override@JsonKey() final  double sunAngle;
 final  List<WeatherKeyframe> _timeline;
@override@JsonKey() List<WeatherKeyframe> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}

/// [EnvironmentAdaptation.automatic] (default) keeps every terrain
/// object (trees) matching this map's own biome.
/// [EnvironmentAdaptation.manual] lets an author mix tree styles
/// instead - e.g. snow-dusted trees on a desert map. Wind type is a
/// separate, always-editable per-keyframe override - see
/// `WeatherKeyframe.resolvedWindType`.
@override@JsonKey() final  EnvironmentAdaptation adaptation;

/// Create a copy of EnvironmentSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnvironmentSettingsCopyWith<_EnvironmentSettings> get copyWith => __$EnvironmentSettingsCopyWithImpl<_EnvironmentSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnvironmentSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnvironmentSettings&&(identical(other.dynamicWeather, dynamicWeather) || other.dynamicWeather == dynamicWeather)&&(identical(other.sunAngle, sunAngle) || other.sunAngle == sunAngle)&&const DeepCollectionEquality().equals(other._timeline, _timeline)&&(identical(other.adaptation, adaptation) || other.adaptation == adaptation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dynamicWeather,sunAngle,const DeepCollectionEquality().hash(_timeline),adaptation);

@override
String toString() {
  return 'EnvironmentSettings(dynamicWeather: $dynamicWeather, sunAngle: $sunAngle, timeline: $timeline, adaptation: $adaptation)';
}


}

/// @nodoc
abstract mixin class _$EnvironmentSettingsCopyWith<$Res> implements $EnvironmentSettingsCopyWith<$Res> {
  factory _$EnvironmentSettingsCopyWith(_EnvironmentSettings value, $Res Function(_EnvironmentSettings) _then) = __$EnvironmentSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool dynamicWeather, double sunAngle, List<WeatherKeyframe> timeline, EnvironmentAdaptation adaptation
});




}
/// @nodoc
class __$EnvironmentSettingsCopyWithImpl<$Res>
    implements _$EnvironmentSettingsCopyWith<$Res> {
  __$EnvironmentSettingsCopyWithImpl(this._self, this._then);

  final _EnvironmentSettings _self;
  final $Res Function(_EnvironmentSettings) _then;

/// Create a copy of EnvironmentSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dynamicWeather = null,Object? sunAngle = null,Object? timeline = null,Object? adaptation = null,}) {
  return _then(_EnvironmentSettings(
dynamicWeather: null == dynamicWeather ? _self.dynamicWeather : dynamicWeather // ignore: cast_nullable_to_non_nullable
as bool,sunAngle: null == sunAngle ? _self.sunAngle : sunAngle // ignore: cast_nullable_to_non_nullable
as double,timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<WeatherKeyframe>,adaptation: null == adaptation ? _self.adaptation : adaptation // ignore: cast_nullable_to_non_nullable
as EnvironmentAdaptation,
  ));
}


}

// dart format on
