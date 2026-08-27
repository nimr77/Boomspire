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

  static Future<ToStore> get instance => _future ??= ToStore.open();

  AppDatabase._();
}
