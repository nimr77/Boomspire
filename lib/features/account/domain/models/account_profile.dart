import 'package:freezed_annotation/freezed_annotation.dart';

import 'account.dart';

part 'account_profile.freezed.dart';

/// An [Account] combined with the player's total score (from
/// `ProgressRepository`) - lets any account-facing UI (name badge, HUD,
/// future leaderboards) show identity + score together via one call,
/// instead of every call site separately loading both repositories.
@freezed
abstract class AccountProfile with _$AccountProfile {
  const factory AccountProfile({
    required Account account,
    required int totalScore,
  }) = _AccountProfile;
}
