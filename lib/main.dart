import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';

import 'core/di/service_locator.dart';
import 'core/router/router.dart';
import 'features/account/domain/models/account.dart';
import 'features/account/domain/repos/account_repository.dart';
import 'features/account/presentation/state/account_profile_state.dart';
import 'features/account/presentation/create_account_content.dart';
import 'features/messaging/presentation/glass_message.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    await windowManager.ensureInitialized();
  }
  runApp(const BoomspireApp());
}

class BoomspireApp extends StatefulWidget {
  const BoomspireApp({super.key});

  @override
  State<BoomspireApp> createState() => _BoomspireAppState();
}

class _BoomspireAppState extends State<BoomspireApp> {
  final AccountRepository _accountRepository = getIt<AccountRepository>();
  final AccountProfileState _accountProfileState = getIt<AccountProfileState>();
  bool _prompted = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      onGenerateTitle: (context) => S.current.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }

  @override
  void initState() {
    super.initState();
    _accountProfileState.refresh();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybePromptForAccount(),
    );
  }

  /// Prompts for a commander name (via the glassy [showGlassMessage] sheet)
  /// on first launch, unless the player already has one or picks Quick Play.
  Future<void> _maybePromptForAccount() async {
    if (_prompted) return;
    _prompted = true;
    final existing = await _accountRepository.currentAccount();
    final navContext = rootNavigatorKey.currentContext;
    if (existing != null || navContext == null || !navContext.mounted) return;
    await showGlassMessage<Account?>(
      navContext,
      barrierDismissible: false,
      contentBuilder: (context) => CreateAccountContent(
        accountRepository: _accountRepository,
        onDone: (account) {
          _accountProfileState.refresh();
          Navigator.of(context).pop(account);
        },
      ),
    );
  }
}
