// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'asset_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssetSource {

 AssetSourceType get type; String get path;
/// Create a copy of AssetSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetSourceCopyWith<AssetSource> get copyWith => _$AssetSourceCopyWithImpl<AssetSource>(this as AssetSource, _$identity);

  /// Serializes this AssetSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetSource&&(identical(other.type, type) || other.type == type)&&(identical(other.path, path) || other.path == path));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,path);

@override
String toString() {
  return 'AssetSource(type: $type, path: $path)';
}


}

/// @nodoc
abstract mixin class $AssetSourceCopyWith<$Res>  {
  factory $AssetSourceCopyWith(AssetSource value, $Res Function(AssetSource) _then) = _$AssetSourceCopyWithImpl;
@useResult
$Res call({
 AssetSourceType type, String path
});




}
/// @nodoc
class _$AssetSourceCopyWithImpl<$Res>
    implements $AssetSourceCopyWith<$Res> {
  _$AssetSourceCopyWithImpl(this._self, this._then);

  final AssetSource _self;
  final $Res Function(AssetSource) _then;

/// Create a copy of AssetSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? path = null,}) {
  return _then(AssetSource(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AssetSourceType,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetSource].
extension AssetSourcePatterns on AssetSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetSource value)  $default,){
final _that = this;
switch (_that) {
case _AssetSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetSource value)?  $default,){
final _that = this;
switch (_that) {
case _AssetSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AssetSourceType type,  String path)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetSource() when $default != null:
return $default(_that.type,_that.path);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AssetSourceType type,  String path)  $default,) {final _that = this;
switch (_that) {
case _AssetSource():
return $default(_that.type,_that.path);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AssetSourceType type,  String path)?  $default,) {final _that = this;
switch (_that) {
case _AssetSource() when $default != null:
return $default(_that.type,_that.path);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssetSource implements AssetSource {
  const _AssetSource({this.type = AssetSourceType.assets, required this.path});
  factory _AssetSource.fromJson(Map<String, dynamic> json) => _$AssetSourceFromJson(json);

@override@JsonKey() final  AssetSourceType type;
@override final  String path;

/// Create a copy of AssetSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetSourceCopyWith<_AssetSource> get copyWith => __$AssetSourceCopyWithImpl<_AssetSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssetSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetSource&&(identical(other.type, type) || other.type == type)&&(identical(other.path, path) || other.path == path));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,path);

@override
String toString() {
  return 'AssetSource(type: $type, path: $path)';
}


}

/// @nodoc
abstract mixin class _$AssetSourceCopyWith<$Res> implements $AssetSourceCopyWith<$Res> {
  factory _$AssetSourceCopyWith(_AssetSource value, $Res Function(_AssetSource) _then) = __$AssetSourceCopyWithImpl;
@override @useResult
$Res call({
 AssetSourceType type, String path
});




}
/// @nodoc
class __$AssetSourceCopyWithImpl<$Res>
    implements _$AssetSourceCopyWith<$Res> {
  __$AssetSourceCopyWithImpl(this._self, this._then);

  final _AssetSource _self;
  final $Res Function(_AssetSource) _then;

/// Create a copy of AssetSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? path = null,}) {
  return _then(_AssetSource(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AssetSourceType,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
