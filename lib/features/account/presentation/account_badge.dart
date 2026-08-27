import 'package:flutter/material.dart';

import '../domain/models/account_profile.dart';
import 'account_avatar.dart';
import 'account_profile_state.dart';

/// Small pill showing the current commander's name + total score, or
/// nothing if no account has been created yet (Quick Play). Listens on the
/// shared [AccountProfileState] instead of re-fetching from the repository
/// on every rebuild.
class AccountBadge extends StatelessWidget {
  final AccountProfileState state;

  const AccountBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountProfile?>(
      valueListenable: state.profile,
      builder: (context, profile, _) {
        if (profile == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AccountAvatar(avatarUrl: profile.account.avatarUrl),
              const SizedBox(width: 6),
              Text(
                profile.account.name,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.military_tech,
                color: Colors.cyanAccent,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '${profile.totalScore}',
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
