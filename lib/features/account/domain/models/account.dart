import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

/// A player's local profile - just a display name for now. Kept separate
/// from [ProgressSnapshot]: this identifies *who* is playing, progress
/// tracks *what* they've done, so a future account-linked backend (e.g.
/// Firebase) can sync one without reshaping the other.
@freezed
abstract class Account with _$Account {
  const factory Account({
    required String id,
    required String name,
    required DateTime createdAt,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
