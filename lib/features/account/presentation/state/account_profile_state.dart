import 'package:flutter/foundation.dart';

import '../domain/models/account_profile.dart';
import '../domain/repos/account_repository.dart';

/// App-wide holder for the current [AccountProfile] (account + score),
/// loaded once on app start and refreshed whenever the account or score
/// changes - lets any widget listen via [profile] instead of re-fetching
/// from [AccountRepository] on every rebuild.
class AccountProfileState {
  final AccountRepository _accountRepository;
  final ValueNotifier<AccountProfile?> _profile = ValueNotifier(null);

  AccountProfileState(this._accountRepository);

  ValueListenable<AccountProfile?> get profile => _profile;

  void dispose() {
    _profile.dispose();
  }

  Future<void> refresh() async {
    _profile.value = await _accountRepository.loadProfile();
  }
}
