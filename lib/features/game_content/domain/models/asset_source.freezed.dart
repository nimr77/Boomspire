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

 String get modelKey; String? get remoteUrl;
/// Create a copy of AssetSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetSourceCopyWith<AssetSource> get copyWith => _$AssetSourceCopyWithImpl<AssetSource>(this as AssetSource, _$identity);

  /// Serializes this AssetSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetSource&&(identical(other.modelKey, modelKey) || other.modelKey == modelKey)&&(identical(other.remoteUrl, remoteUrl) || other.remoteUrl == remoteUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,modelKey,remoteUrl);

@override
String toString() {
  return 'AssetSource(modelKey: $modelKey, remoteUrl: $remoteUrl)';
}


}

/// @nodoc
abstract mixin class $AssetSourceCopyWith<$Res>  {
  factory $AssetSourceCopyWith(AssetSource value, $Res Function(AssetSource) _then) = _$AssetSourceCopyWithImpl;
@useResult
$Res call({
 String modelKey, String? remoteUrl
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
@pragma('vm:prefer-inline') @override $Res call({Object? modelKey = null,Object? remoteUrl = freezed,}) {
  return _then(AssetSource(
modelKey: null == modelKey ? _self.modelKey : modelKey // ignore: cast_nullable_to_non_nullable
as String,remoteUrl: freezed == remoteUrl ? _self.remoteUrl : remoteUrl // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String modelKey,  String? remoteUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetSource() when $default != null:
return $default(_that.modelKey,_that.remoteUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String modelKey,  String? remoteUrl)  $default,) {final _that = this;
switch (_that) {
case _AssetSource():
return $default(_that.modelKey,_that.remoteUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String modelKey,  String? remoteUrl)?  $default,) {final _that = this;
switch (_that) {
case _AssetSource() when $default != null:
return $default(_that.modelKey,_that.remoteUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssetSource implements AssetSource {
  const _AssetSource({required this.modelKey, this.remoteUrl});
  factory _AssetSource.fromJson(Map<String, dynamic> json) => _$AssetSourceFromJson(json);

@override final  String modelKey;
@override final  String? remoteUrl;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetSource&&(identical(other.modelKey, modelKey) || other.modelKey == modelKey)&&(identical(other.remoteUrl, remoteUrl) || other.remoteUrl == remoteUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,modelKey,remoteUrl);

@override
String toString() {
  return 'AssetSource(modelKey: $modelKey, remoteUrl: $remoteUrl)';
}


}

/// @nodoc
abstract mixin class _$AssetSourceCopyWith<$Res> implements $AssetSourceCopyWith<$Res> {
  factory _$AssetSourceCopyWith(_AssetSource value, $Res Function(_AssetSource) _then) = __$AssetSourceCopyWithImpl;
@override @useResult
$Res call({
 String modelKey, String? remoteUrl
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
@override @pragma('vm:prefer-inline') $Res call({Object? modelKey = null,Object? remoteUrl = freezed,}) {
  return _then(_AssetSource(
modelKey: null == modelKey ? _self.modelKey : modelKey // ignore: cast_nullable_to_non_nullable
as String,remoteUrl: freezed == remoteUrl ? _self.remoteUrl : remoteUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
