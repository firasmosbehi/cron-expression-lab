// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cron_expr_app/main.dart';

void main() {
  testWidgets('Cron app renders and shows default expression', (tester) async {
    await tester.pumpWidget(const CronApp());

    expect(find.text('Cron Expression Generator & Tester'), findsOneWidget);

    final field = find.byType(TextFormField);
    expect(field, findsOneWidget);
    final textField = tester.widget<TextFormField>(field);
    expect(textField.controller?.text, '0 0 * * *');

    // Trigger the test button to generate occurrences.
    final testLabel = find.text('Test');
    expect(testLabel, findsOneWidget);
    await tester.tap(testLabel);
    await tester.pumpAndSettle();

    // Should list at least one upcoming run.
    expect(find.byIcon(Icons.event_available), findsWidgets);
  });
}
