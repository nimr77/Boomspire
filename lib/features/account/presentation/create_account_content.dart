import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../../theme/app_theme/app_theme_colors.dart';
import '../../../theme/app_theme/app_theme_paddings.dart';
import '../../../theme/app_theme/app_theme_spacing.dart';
import '../domain/models/account.dart';
import '../domain/repos/account_repository.dart';

/// Content shown inside the glass "messaging" sheet at first launch: pick a
/// commander name (persisted via [AccountRepository]) or skip straight in
/// with Quick Play.
class CreateAccountContent extends StatefulWidget {
  final AccountRepository accountRepository;
  final ValueChanged<Account?> onDone;

  const CreateAccountContent({
    super.key,
    required this.accountRepository,
    required this.onDone,
  });

  @override
  State<CreateAccountContent> createState() => _CreateAccountContentState();
}

class _CreateAccountContentState extends State<CreateAccountContent> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _submitting = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.current.accountWelcomeTitle,
            style: const TextStyle(
              color: AppThemeColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppThemeSpacing.space8),
          Text(
            S.current.accountWelcomeSubtitle,
            style: const TextStyle(color: AppThemeColors.textMuted, fontSize: 14),
          ),
          SizedBox(height: AppThemeSpacing.space22),
          TextFormField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: AppThemeColors.textPrimary),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _continue(),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? S.current.accountNameRequired
                : null,
            decoration: InputDecoration(
              hintText: S.current.accountNameHint,
              hintStyle: const TextStyle(color: AppThemeColors.textFaint),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: AppThemePaddings.h16v14,
            ),
          ),
          SizedBox(height: AppThemeSpacing.space20),
          ValueListenableBuilder<bool>(
            valueListenable: _submitting,
            builder: (context, submitting, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitting ? null : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeColors.accentLightBlue,
                        foregroundColor: AppThemeColors.textOnAccent,
                        padding: AppThemePaddings.v14,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        S.current.accountContinue,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppThemeSpacing.space10),
                  Center(
                    child: TextButton(
                      onPressed: submitting ? null : () => widget.onDone(null),
                      child: Text(
                        S.current.accountQuickPlay,
                        style: const TextStyle(color: AppThemeColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _submitting.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _submitting.value = true;
    final account = await widget.accountRepository.createAccount(
      name: _controller.text,
    );
    if (!mounted) return;
    widget.onDone(account);
  }
}
