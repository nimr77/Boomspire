import 'package:flutter/material.dart';

import '../../../theme/app_theme/app_theme_colors.dart';
import '../../../theme/app_theme/app_theme_paddings.dart';
import '../../../theme/app_theme/app_theme_spacing.dart';
import '../domain/models/account_profile.dart';
import 'account_avatar.dart';
import 'state/account_profile_state.dart';

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
          padding: AppThemePaddings.bottom18,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AccountAvatar(avatarUrl: profile.account.avatarUrl),
              SizedBox(width: AppThemeSpacing.space6),
              Text(
                profile.account.name,
                style: const TextStyle(
                  color: AppThemeColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: AppThemeSpacing.space14),
              const Icon(
                Icons.military_tech,
                color: AppThemeColors.accentCyan,
                size: 18,
              ),
              SizedBox(width: AppThemeSpacing.space6),
              Text(
                '${profile.totalScore}',
                style: const TextStyle(
                  color: AppThemeColors.accentCyan,
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
