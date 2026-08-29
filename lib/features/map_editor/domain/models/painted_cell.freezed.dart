// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'painted_cell.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaintedCell {

 int get col; int get row; ObstacleKind get kind;/// Overrides which [Biome]'s palette this one obstacle renders with,
/// instead of the map's own biome (e.g. a snow-capped mountain dropped
/// into a desert map) - null means "render with the map's own biome",
/// matching every cell painted before this brush-type feature existed.
 Biome? get variant;
/// Create a copy of PaintedCell
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaintedCellCopyWith<PaintedCell> get copyWith => _$PaintedCellCopyWithImpl<PaintedCell>(this as PaintedCell, _$identity);

  /// Serializes this PaintedCell to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaintedCell&&(identical(other.col, col) || other.col == col)&&(identical(other.row, row) || other.row == row)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.variant, variant) || other.variant == variant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,col,row,kind,variant);

@override
String toString() {
  return 'PaintedCell(col: $col, row: $row, kind: $kind, variant: $variant)';
}


}

/// @nodoc
abstract mixin class $PaintedCellCopyWith<$Res>  {
  factory $PaintedCellCopyWith(PaintedCell value, $Res Function(PaintedCell) _then) = _$PaintedCellCopyWithImpl;
@useResult
$Res call({
 int col, int row, ObstacleKind kind, Biome? variant
});




}
/// @nodoc
class _$PaintedCellCopyWithImpl<$Res>
    implements $PaintedCellCopyWith<$Res> {
  _$PaintedCellCopyWithImpl(this._self, this._then);

  final PaintedCell _self;
  final $Res Function(PaintedCell) _then;

/// Create a copy of PaintedCell
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? col = null,Object? row = null,Object? kind = null,Object? variant = freezed,}) {
  return _then(PaintedCell(
col: null == col ? _self.col : col // ignore: cast_nullable_to_non_nullable
as int,row: null == row ? _self.row : row // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ObstacleKind,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as Biome?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaintedCell].
extension PaintedCellPatterns on PaintedCell {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaintedCell value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaintedCell() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaintedCell value)  $default,){
final _that = this;
switch (_that) {
case _PaintedCell():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaintedCell value)?  $default,){
final _that = this;
switch (_that) {
case _PaintedCell() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int col,  int row,  ObstacleKind kind,  Biome? variant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaintedCell() when $default != null:
return $default(_that.col,_that.row,_that.kind,_that.variant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int col,  int row,  ObstacleKind kind,  Biome? variant)  $default,) {final _that = this;
switch (_that) {
case _PaintedCell():
return $default(_that.col,_that.row,_that.kind,_that.variant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int col,  int row,  ObstacleKind kind,  Biome? variant)?  $default,) {final _that = this;
switch (_that) {
case _PaintedCell() when $default != null:
return $default(_that.col,_that.row,_that.kind,_that.variant);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaintedCell implements PaintedCell {
  const _PaintedCell({required this.col, required this.row, required this.kind, this.variant});
  factory _PaintedCell.fromJson(Map<String, dynamic> json) => _$PaintedCellFromJson(json);

@override final  int col;
@override final  int row;
@override final  ObstacleKind kind;
/// Overrides which [Biome]'s palette this one obstacle renders with,
/// instead of the map's own biome (e.g. a snow-capped mountain dropped
/// into a desert map) - null means "render with the map's own biome",
/// matching every cell painted before this brush-type feature existed.
@override final  Biome? variant;

/// Create a copy of PaintedCell
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaintedCellCopyWith<_PaintedCell> get copyWith => __$PaintedCellCopyWithImpl<_PaintedCell>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaintedCellToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaintedCell&&(identical(other.col, col) || other.col == col)&&(identical(other.row, row) || other.row == row)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.variant, variant) || other.variant == variant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,col,row,kind,variant);

@override
String toString() {
  return 'PaintedCell(col: $col, row: $row, kind: $kind, variant: $variant)';
}


}

/// @nodoc
abstract mixin class _$PaintedCellCopyWith<$Res> implements $PaintedCellCopyWith<$Res> {
  factory _$PaintedCellCopyWith(_PaintedCell value, $Res Function(_PaintedCell) _then) = __$PaintedCellCopyWithImpl;
@override @useResult
$Res call({
 int col, int row, ObstacleKind kind, Biome? variant
});




}
/// @nodoc
class __$PaintedCellCopyWithImpl<$Res>
    implements _$PaintedCellCopyWith<$Res> {
  __$PaintedCellCopyWithImpl(this._self, this._then);

  final _PaintedCell _self;
  final $Res Function(_PaintedCell) _then;

/// Create a copy of PaintedCell
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? col = null,Object? row = null,Object? kind = null,Object? variant = freezed,}) {
  return _then(_PaintedCell(
col: null == col ? _self.col : col // ignore: cast_nullable_to_non_nullable
as int,row: null == row ? _self.row : row // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ObstacleKind,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as Biome?,
  ));
}


}

// dart format on
