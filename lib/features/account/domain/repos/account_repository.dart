import '../models/account.dart';

/// Manages the player's local profile/identity.
///
/// Kept storage-agnostic (like [ProgressRepository]) so a
/// `FirebaseAccountRepositoryImpl` can later implement the same interface
/// for signed-in play, without any call site needing to change.
abstract class AccountRepository {
  /// The currently saved account, if the player has created one.
  Future<Account?> currentAccount();

  /// Creates (and persists) a new local account with the given [name].
  Future<Account> createAccount({required String name});

  /// Clears the saved account (e.g. to let the player pick a new name).
  Future<void> signOut();
}
