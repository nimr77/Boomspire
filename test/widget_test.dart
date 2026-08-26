import 'package:boomspire/core/di/service_locator.dart';
import 'package:boomspire/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Boomspire app boots and shows the game canvas', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    setupServiceLocator();
    await tester.pumpWidget(const BoomspireApp());
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
