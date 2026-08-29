import 'package:boomspire/core/di/service_locator.dart';
import 'package:boomspire/features/account/domain/models/account.dart';
import 'package:boomspire/features/account/domain/models/account_profile.dart';
import 'package:boomspire/features/account/domain/repos/account_repository.dart';
import 'package:boomspire/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Boomspire app boots and shows the game canvas', (
    WidgetTester tester,
  ) async {
    setupServiceLocator();
    // Swap in a fake so this smoke test never touches the real on-device
    // ToStore engine (and its background compaction/TTL/idle timers, which
    // don't play well with flutter_test's "no pending timers" invariant).
    getIt.unregister<AccountRepository>();
    getIt.registerLazySingleton<AccountRepository>(_FakeAccountRepository.new);

    await tester.pumpWidget(const BoomspireApp());
    // Not pumpAndSettle: the main menu's AppShellWidget mesh-gradient
    // background animates perpetually, so "settle" (no more frames
    // scheduled) never actually happens - a few bounded pumps are enough
    // for the initial route to build.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(Scaffold), findsOneWidget);
  });
}

class _FakeAccountRepository implements AccountRepository {
  @override
  Future<Account> createAccount({
    required String name,
    String? avatarUrl,
  }) async => Account(
    id: 'test',
    name: name,
    createdAt: DateTime.now(),
    avatarUrl: avatarUrl,
  );

  @override
  Future<Account?> currentAccount() async => null;

  @override
  Future<AccountProfile?> loadProfile() async => null;

  @override
  Future<void> signOut() async {}
}
