import '../../../generated/l10n.dart';
import '../domain/enums/editor_tool.dart';

/// Localized display label for each [EditorTool].
extension EditorToolExtensions on EditorTool {
  String get label => switch (this) {
    EditorTool.mountain => S.current.mountainLabelEditorPage,
    EditorTool.dune => S.current.duneLabelEditorPage,
    EditorTool.tree => S.current.treeLabelEditorPage,
    EditorTool.erase => S.current.eraseLabelEditorPage,
    EditorTool.river => S.current.riverLabelEditorPage,
    EditorTool.lake => S.current.lakeLabelEditorPage,
    EditorTool.homeSite => S.current.homeLabelEditorPage,
  };
}
