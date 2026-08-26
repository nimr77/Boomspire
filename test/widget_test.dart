import 'package:circuit_defense/core/di/service_locator.dart';
import 'package:circuit_defense/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Circuit Defense app boots and shows the game canvas', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    setupServiceLocator();
    await tester.pumpWidget(const CircuitDefenseApp());
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
