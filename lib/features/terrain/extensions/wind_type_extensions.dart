import '../../../generated/l10n.dart';
import '../domain/enums/wind_type.dart';

extension WindTypeExtensions on WindType {
  String get label => switch (this) {
    WindType.automatic => S.current.windTypeAutomaticEditorPage,
    WindType.grassLeaves => S.current.windTypeGrassLeavesEditorPage,
    WindType.autumnLeaves => S.current.windTypeAutumnLeavesEditorPage,
    WindType.sand => S.current.windTypeSandEditorPage,
    WindType.dust => S.current.windTypeDustEditorPage,
    WindType.snow => S.current.windTypeSnowEditorPage,
    WindType.ash => S.current.windTypeAshEditorPage,
  };
}
