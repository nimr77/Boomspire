// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sound_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SoundRef {

 SfxType? get builtIn; String? get remoteUrl;
/// Create a copy of SoundRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoundRefCopyWith<SoundRef> get copyWith => _$SoundRefCopyWithImpl<SoundRef>(this as SoundRef, _$identity);

  /// Serializes this SoundRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SoundRef&&(identical(other.builtIn, builtIn) || other.builtIn == builtIn)&&(identical(other.remoteUrl, remoteUrl) || other.remoteUrl == remoteUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,builtIn,remoteUrl);

@override
String toString() {
  return 'SoundRef(builtIn: $builtIn, remoteUrl: $remoteUrl)';
}


}

/// @nodoc
abstract mixin class $SoundRefCopyWith<$Res>  {
  factory $SoundRefCopyWith(SoundRef value, $Res Function(SoundRef) _then) = _$SoundRefCopyWithImpl;
@useResult
$Res call({
 SfxType? builtIn, String? remoteUrl
});




}
/// @nodoc
class _$SoundRefCopyWithImpl<$Res>
    implements $SoundRefCopyWith<$Res> {
  _$SoundRefCopyWithImpl(this._self, this._then);

  final SoundRef _self;
  final $Res Function(SoundRef) _then;

/// Create a copy of SoundRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? builtIn = freezed,Object? remoteUrl = freezed,}) {
  return _then(SoundRef(
builtIn: freezed == builtIn ? _self.builtIn : builtIn // ignore: cast_nullable_to_non_nullable
as SfxType?,remoteUrl: freezed == remoteUrl ? _self.remoteUrl : remoteUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SoundRef].
extension SoundRefPatterns on SoundRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SoundRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SoundRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SoundRef value)  $default,){
final _that = this;
switch (_that) {
case _SoundRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SoundRef value)?  $default,){
final _that = this;
switch (_that) {
case _SoundRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SfxType? builtIn,  String? remoteUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SoundRef() when $default != null:
return $default(_that.builtIn,_that.remoteUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SfxType? builtIn,  String? remoteUrl)  $default,) {final _that = this;
switch (_that) {
case _SoundRef():
return $default(_that.builtIn,_that.remoteUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SfxType? builtIn,  String? remoteUrl)?  $default,) {final _that = this;
switch (_that) {
case _SoundRef() when $default != null:
return $default(_that.builtIn,_that.remoteUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SoundRef implements SoundRef {
  const _SoundRef({this.builtIn, this.remoteUrl});
  factory _SoundRef.fromJson(Map<String, dynamic> json) => _$SoundRefFromJson(json);

@override final  SfxType? builtIn;
@override final  String? remoteUrl;

/// Create a copy of SoundRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SoundRefCopyWith<_SoundRef> get copyWith => __$SoundRefCopyWithImpl<_SoundRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SoundRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SoundRef&&(identical(other.builtIn, builtIn) || other.builtIn == builtIn)&&(identical(other.remoteUrl, remoteUrl) || other.remoteUrl == remoteUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,builtIn,remoteUrl);

@override
String toString() {
  return 'SoundRef(builtIn: $builtIn, remoteUrl: $remoteUrl)';
}


}

/// @nodoc
abstract mixin class _$SoundRefCopyWith<$Res> implements $SoundRefCopyWith<$Res> {
  factory _$SoundRefCopyWith(_SoundRef value, $Res Function(_SoundRef) _then) = __$SoundRefCopyWithImpl;
@override @useResult
$Res call({
 SfxType? builtIn, String? remoteUrl
});




}
/// @nodoc
class __$SoundRefCopyWithImpl<$Res>
    implements _$SoundRefCopyWith<$Res> {
  __$SoundRefCopyWithImpl(this._self, this._then);

  final _SoundRef _self;
  final $Res Function(_SoundRef) _then;

/// Create a copy of SoundRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? builtIn = freezed,Object? remoteUrl = freezed,}) {
  return _then(_SoundRef(
builtIn: freezed == builtIn ? _self.builtIn : builtIn // ignore: cast_nullable_to_non_nullable
as SfxType?,remoteUrl: freezed == remoteUrl ? _self.remoteUrl : remoteUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
