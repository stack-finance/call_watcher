// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:call_watcher_example/main.dart';

void main() {

  const dummyNumber = '1234567890';

  /// verify if app launches
  testWidgets('Verify app launches', (WidgetTester tester) async {

    await tester.pumpWidget(const MyApp());

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
  });

  /// verify if app can initiate a call
  testWidgets('Verify app can initiate a call', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.enterText(find.byType(TextField), dummyNumber);

    // find icon button and press
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text(dummyNumber), findsOneWidget);
  });

  /// verify if app can get last called number
  testWidgets('Verify app can get last called number', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text(dummyNumber), findsNothing);
  });
}
