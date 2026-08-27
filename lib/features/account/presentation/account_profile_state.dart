import 'package:flutter/foundation.dart';

import '../domain/models/account_profile.dart';
import '../domain/repos/account_repository.dart';

/// App-wide holder for the current [AccountProfile] (account + score),
/// loaded once on app start and refreshed whenever the account or score
/// changes - lets any widget listen via [profile] instead of re-fetching
/// from [AccountRepository] on every rebuild.
class AccountProfileState {
  final AccountRepository _accountRepository;
  final ValueNotifier<AccountProfile?> profile = ValueNotifier(null);

  AccountProfileState(this._accountRepository);

  Future<void> refresh() async {
    profile.value = await _accountRepository.loadProfile();
  }
}
