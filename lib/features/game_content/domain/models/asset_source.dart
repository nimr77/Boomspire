import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/asset_source_type.dart';

export '../enums/asset_source_type.dart';

part 'asset_source.freezed.dart';
part 'asset_source.g.dart';

/// Where a [GameObjectDefinition] gets its visuals from - [type] says which
/// implementation should load [path]: [AssetSourceType.assets] keys into the
/// bundled `assets/models/<path>.json` catalog already used by
/// `UnitRenderRepository` (Procedural/Lottie/Rive/Composite);
/// [AssetSourceType.remote] fetches [path] as a URL instead.
@freezed
abstract class AssetSource with _$AssetSource {
  const factory AssetSource({
    @Default(AssetSourceType.assets) AssetSourceType type,
    required String path,
  }) = _AssetSource;

  factory AssetSource.fromJson(Map<String, dynamic> json) =>
      _$AssetSourceFromJson(json);
}
