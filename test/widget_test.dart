import 'package:circuit_defense/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Circuit Defense app boots and shows the game canvas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CircuitDefenseApp());
    await tester.pump();

    expect(find.byType(Scaffold), findsOneWidget);
  });
}

