import 'dart:math';

import '../../../core/storage/app_database.dart';
import '../domain/models/account.dart';
import '../domain/repos/account_repository.dart';

/// On-device account storage via ToStore's key-value engine - the default
/// for players who haven't (yet) signed into a cloud account. A future
/// `FirebaseAccountRepositoryImpl` implementing [AccountRepository] can
/// replace this once real accounts exist, without touching UI code.
class LocalAccountRepositoryImpl implements AccountRepository {
  static const _key = 'boomspire.account.v1';

  @override
  Future<Account> createAccount({required String name}) async {
    final trimmed = name.trim();
    final account = Account(
      id: _generateId(),
      name: trimmed.isEmpty ? 'Commander' : trimmed,
      createdAt: DateTime.now(),
    );
    final db = await AppDatabase.instance;
    await db.setValue(_key, account.toJson());
    return account;
  }

  @override
  Future<Account?> currentAccount() async {
    final db = await AppDatabase.instance;
    final raw = await db.getValue(_key);
    if (raw == null) return null;
    try {
      return Account.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    final db = await AppDatabase.instance;
    await db.removeValue(_key);
  }

  String _generateId() {
    final rnd = Random();
    return List.generate(16, (_) => rnd.nextInt(16).toRadixString(16)).join();
  }
}
