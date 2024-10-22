// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:call_watcher/call_watcher.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const dummyNumber = '1234567890';

  testWidgets('initate call', (WidgetTester tester) async {
    final CallWatcher plugin = CallWatcher();
    await plugin.initiateCall(dummyNumber);
  });

  /// should save last called number to shared preferences
  testWidgets('get last called number', (WidgetTester tester) async {
    final CallWatcher plugin = CallWatcher();
    String? lastCalledNumber = await plugin.getLastCalledNumber();

    expect(lastCalledNumber, dummyNumber);
  });
}
