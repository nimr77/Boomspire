// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tree_cell.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TreeCell {

 int get col; int get row;
/// Create a copy of TreeCell
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TreeCellCopyWith<TreeCell> get copyWith => _$TreeCellCopyWithImpl<TreeCell>(this as TreeCell, _$identity);

  /// Serializes this TreeCell to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TreeCell&&(identical(other.col, col) || other.col == col)&&(identical(other.row, row) || other.row == row));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,col,row);

@override
String toString() {
  return 'TreeCell(col: $col, row: $row)';
}


}

/// @nodoc
abstract mixin class $TreeCellCopyWith<$Res>  {
  factory $TreeCellCopyWith(TreeCell value, $Res Function(TreeCell) _then) = _$TreeCellCopyWithImpl;
@useResult
$Res call({
 int col, int row
});




}
/// @nodoc
class _$TreeCellCopyWithImpl<$Res>
    implements $TreeCellCopyWith<$Res> {
  _$TreeCellCopyWithImpl(this._self, this._then);

  final TreeCell _self;
  final $Res Function(TreeCell) _then;

/// Create a copy of TreeCell
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? col = null,Object? row = null,}) {
  return _then(TreeCell(
col: null == col ? _self.col : col // ignore: cast_nullable_to_non_nullable
as int,row: null == row ? _self.row : row // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TreeCell].
extension TreeCellPatterns on TreeCell {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TreeCell value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TreeCell() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TreeCell value)  $default,){
final _that = this;
switch (_that) {
case _TreeCell():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TreeCell value)?  $default,){
final _that = this;
switch (_that) {
case _TreeCell() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int col,  int row)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TreeCell() when $default != null:
return $default(_that.col,_that.row);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int col,  int row)  $default,) {final _that = this;
switch (_that) {
case _TreeCell():
return $default(_that.col,_that.row);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int col,  int row)?  $default,) {final _that = this;
switch (_that) {
case _TreeCell() when $default != null:
return $default(_that.col,_that.row);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TreeCell implements TreeCell {
  const _TreeCell({required this.col, required this.row});
  factory _TreeCell.fromJson(Map<String, dynamic> json) => _$TreeCellFromJson(json);

@override final  int col;
@override final  int row;

/// Create a copy of TreeCell
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TreeCellCopyWith<_TreeCell> get copyWith => __$TreeCellCopyWithImpl<_TreeCell>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TreeCellToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TreeCell&&(identical(other.col, col) || other.col == col)&&(identical(other.row, row) || other.row == row));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,col,row);

@override
String toString() {
  return 'TreeCell(col: $col, row: $row)';
}


}

/// @nodoc
abstract mixin class _$TreeCellCopyWith<$Res> implements $TreeCellCopyWith<$Res> {
  factory _$TreeCellCopyWith(_TreeCell value, $Res Function(_TreeCell) _then) = __$TreeCellCopyWithImpl;
@override @useResult
$Res call({
 int col, int row
});




}
/// @nodoc
class __$TreeCellCopyWithImpl<$Res>
    implements _$TreeCellCopyWith<$Res> {
  __$TreeCellCopyWithImpl(this._self, this._then);

  final _TreeCell _self;
  final $Res Function(_TreeCell) _then;

/// Create a copy of TreeCell
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? col = null,Object? row = null,}) {
  return _then(_TreeCell(
col: null == col ? _self.col : col // ignore: cast_nullable_to_non_nullable
as int,row: null == row ? _self.row : row // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
