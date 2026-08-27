import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:tostore/tostore.dart';

/// Shared on-device [ToStore] key-value engine used for every local-only
/// persistence need (account, progress, map drafts) - opened once and
/// reused everywhere so all repos talk to the same underlying engine
/// instance/cache instead of each spinning up its own database.
///
/// This replaces the previous `shared_preferences`-backed storage; ToStore
/// gives the same "just stash a JSON blob under a key" ergonomics via its
/// key-value mode (`setValue`/`getValue`/`removeValue`), but with a real
/// storage engine (crash recovery, indexing, etc.) instead of a thin
/// wrapper over native platform prefs.
class AppDatabase {
  static Future<ToStore>? _future;
  static Future<ToStore> Function() _factory = ToStore.open;

  static Future<ToStore> get instance => _future ??= _factory();

  AppDatabase._();

  /// Test-only hook: drop the cached instance (and any override set via
  /// [useForTest]) so the next [instance] access opens fresh. Closes the
  /// current instance first so it doesn't leave background maintenance
  /// timers (compaction, TTL cleanup, etc.) running past the end of a test.
  @visibleForTesting
  static Future<void> reset() async {
    final pending = _future;
    _future = null;
    _factory = ToStore.open;
    if (pending != null) {
      try {
        await (await pending).close();
      } catch (_) {
        // Best-effort - a never-opened/already-closed instance is fine.
      }
    }
  }

  /// Test-only hook: swap in an isolated database (e.g. `ToStore.memory`)
  /// so tests don't read/write the real on-device store or leak state
  /// between test runs. Pair with [reset] in `tearDown`.
  @visibleForTesting
  static void useForTest(Future<ToStore> Function() factory) {
    _factory = factory;
    _future = null;
  }
}
