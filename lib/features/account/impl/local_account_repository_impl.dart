import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/account.dart';
import '../domain/repos/account_repository.dart';

/// On-device account storage via `shared_preferences` - the default for
/// players who haven't (yet) signed into a cloud account. A future
/// `FirebaseAccountRepositoryImpl` implementing [AccountRepository] can
/// replace this once real accounts exist, without touching UI code.
class LocalAccountRepositoryImpl implements AccountRepository {
  static const _key = 'circuit_defense.account.v1';

  @override
  Future<Account?> currentAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return Account.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Account> createAccount({required String name}) async {
    final trimmed = name.trim();
    final account = Account(
      id: _generateId(),
      name: trimmed.isEmpty ? 'Commander' : trimmed,
      createdAt: DateTime.now(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(account.toJson()));
    return account;
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  String _generateId() {
    final rnd = Random();
    return List.generate(16, (_) => rnd.nextInt(16).toRadixString(16)).join();
  }
}
