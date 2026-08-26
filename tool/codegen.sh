#!/usr/bin/env bash
# Regenerates all generated code for this project:
#  - freezed/json_serializable data classes (*.freezed.dart / *.g.dart)
#  - flutter_gen typed asset accessors (lib/gen/assets.gen.dart)
#  - flutter_intl (S / S.current) localization from lib/l10n/*.arb
#
# Run this after changing a @freezed model, adding/removing assets, or
# editing an .arb file.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "==> build_runner (freezed + json_serializable)"
dart run build_runner build

echo "==> flutter_gen (typed asset accessors)"
# Note: flutter_gen_runner's build_runner integration doesn't reliably write
# lib/gen/assets.gen.dart in this project (only a manifest, verified during
# setup) - the standalone `fluttergen` CLI does. Activate once with:
#   dart pub global activate flutter_gen
if command -v fluttergen >/dev/null 2>&1; then
  fluttergen
else
  ~/.pub-cache/bin/fluttergen
fi

echo "==> intl_utils (S.current localization)"
dart run intl_utils:generate

echo "Done."
