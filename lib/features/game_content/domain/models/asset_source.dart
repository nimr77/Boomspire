import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_source.freezed.dart';
part 'asset_source.g.dart';

/// Where a [GameObjectDefinition] gets its visuals from - a key into the
/// bundled `assets/models/<modelKey>.json` catalog already used by
/// `UnitRenderRepository` (Procedural/Lottie/Rive/Composite), or a
/// server-hosted override fetched and cached alongside the manifest itself.
@freezed
abstract class AssetSource with _$AssetSource {
  const factory AssetSource({
    required String modelKey,
    String? remoteUrl,
  }) = _AssetSource;

  factory AssetSource.fromJson(Map<String, dynamic> json) =>
      _$AssetSourceFromJson(json);
}
