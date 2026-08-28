import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/sound_source_type.dart';

export '../enums/sound_source_type.dart';

part 'sound_ref.freezed.dart';
part 'sound_ref.g.dart';

/// Which sound a [GameObjectDefinition] plays - [type] says which
/// implementation should resolve [path]: [SoundSourceType.builtIn] keys into
/// an existing bundled `SfxType`'s name (the common case, keeps using
/// `AudioRepository` as-is); [SoundSourceType.remote] fetches [path] as a
/// URL instead. A null [type] means no sound is assigned yet.
@freezed
abstract class SoundRef with _$SoundRef {
  const factory SoundRef({SoundSourceType? type, String? path}) = _SoundRef;

  factory SoundRef.fromJson(Map<String, dynamic> json) =>
      _$SoundRefFromJson(json);
}
