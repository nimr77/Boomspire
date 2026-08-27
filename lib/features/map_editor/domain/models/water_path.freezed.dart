// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'water_path.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WaterPath {

 WaterFeatureKind get kind; List<EditorPoint> get points; double get width;
/// Create a copy of WaterPath
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaterPathCopyWith<WaterPath> get copyWith => _$WaterPathCopyWithImpl<WaterPath>(this as WaterPath, _$identity);

  /// Serializes this WaterPath to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WaterPath&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.width, width) || other.width == width));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,const DeepCollectionEquality().hash(points),width);

@override
String toString() {
  return 'WaterPath(kind: $kind, points: $points, width: $width)';
}


}

/// @nodoc
abstract mixin class $WaterPathCopyWith<$Res>  {
  factory $WaterPathCopyWith(WaterPath value, $Res Function(WaterPath) _then) = _$WaterPathCopyWithImpl;
@useResult
$Res call({
 WaterFeatureKind kind, List<EditorPoint> points, double width
});




}
/// @nodoc
class _$WaterPathCopyWithImpl<$Res>
    implements $WaterPathCopyWith<$Res> {
  _$WaterPathCopyWithImpl(this._self, this._then);

  final WaterPath _self;
  final $Res Function(WaterPath) _then;

/// Create a copy of WaterPath
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? points = null,Object? width = null,}) {
  return _then(WaterPath(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as WaterFeatureKind,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<EditorPoint>,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [WaterPath].
extension WaterPathPatterns on WaterPath {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WaterPath value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WaterPath() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WaterPath value)  $default,){
final _that = this;
switch (_that) {
case _WaterPath():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WaterPath value)?  $default,){
final _that = this;
switch (_that) {
case _WaterPath() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WaterFeatureKind kind,  List<EditorPoint> points,  double width)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WaterPath() when $default != null:
return $default(_that.kind,_that.points,_that.width);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WaterFeatureKind kind,  List<EditorPoint> points,  double width)  $default,) {final _that = this;
switch (_that) {
case _WaterPath():
return $default(_that.kind,_that.points,_that.width);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WaterFeatureKind kind,  List<EditorPoint> points,  double width)?  $default,) {final _that = this;
switch (_that) {
case _WaterPath() when $default != null:
return $default(_that.kind,_that.points,_that.width);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WaterPath implements WaterPath {
  const _WaterPath({required this.kind, required  List<EditorPoint> points, this.width = 48.0}): _points = points;
  factory _WaterPath.fromJson(Map<String, dynamic> json) => _$WaterPathFromJson(json);

@override final  WaterFeatureKind kind;
 final  List<EditorPoint> _points;
@override List<EditorPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override@JsonKey() final  double width;

/// Create a copy of WaterPath
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WaterPathCopyWith<_WaterPath> get copyWith => __$WaterPathCopyWithImpl<_WaterPath>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WaterPathToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WaterPath&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.width, width) || other.width == width));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,const DeepCollectionEquality().hash(_points),width);

@override
String toString() {
  return 'WaterPath(kind: $kind, points: $points, width: $width)';
}


}

/// @nodoc
abstract mixin class _$WaterPathCopyWith<$Res> implements $WaterPathCopyWith<$Res> {
  factory _$WaterPathCopyWith(_WaterPath value, $Res Function(_WaterPath) _then) = __$WaterPathCopyWithImpl;
@override @useResult
$Res call({
 WaterFeatureKind kind, List<EditorPoint> points, double width
});




}
/// @nodoc
class __$WaterPathCopyWithImpl<$Res>
    implements _$WaterPathCopyWith<$Res> {
  __$WaterPathCopyWithImpl(this._self, this._then);

  final _WaterPath _self;
  final $Res Function(_WaterPath) _then;

/// Create a copy of WaterPath
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? points = null,Object? width = null,}) {
  return _then(_WaterPath(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as WaterFeatureKind,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<EditorPoint>,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
