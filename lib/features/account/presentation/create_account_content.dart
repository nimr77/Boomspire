import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
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
  bool _submitting = false;

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
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.current.accountWelcomeSubtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _continue(),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? S.current.accountNameRequired
                : null,
            decoration: InputDecoration(
              hintText: S.current.accountNameHint,
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _continue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
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
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: _submitting ? null : () => widget.onDone(null),
              child: Text(
                S.current.accountQuickPlay,
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final account = await widget.accountRepository.createAccount(
      name: _controller.text,
    );
    if (!mounted) return;
    widget.onDone(account);
  }
}
