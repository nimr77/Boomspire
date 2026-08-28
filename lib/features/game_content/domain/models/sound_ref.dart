import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../audio/domain/enums/sfx_type.dart';

part 'sound_ref.freezed.dart';
part 'sound_ref.g.dart';

/// Which sound a [GameObjectDefinition] plays - either an existing bundled
/// [SfxType] (the common case, keeps using `AudioRepository` as-is) or a
/// server-hosted sound asset for content the built-in SFX set has no
/// equivalent for.
@freezed
abstract class SoundRef with _$SoundRef {
  const factory SoundRef({SfxType? builtIn, String? remoteUrl}) = _SoundRef;

  factory SoundRef.fromJson(Map<String, dynamic> json) =>
      _$SoundRefFromJson(json);
}
