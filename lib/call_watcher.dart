import 'dart:io';

import 'package:call_watcher/models/call_log.dart';
import 'package:call_watcher/models/log_query.dart';

import 'call_watcher_platform_interface.dart';
export 'models/models.dart';

class CallWatcher {
  static Future<String?> getLastCalledNumber() {
    return CallWatcherPlatform.instance.getLastCalledNumber();
  }

  static Future<List<CallLogEntry>?> getCallLogs({int limit = 100}) {
    return CallWatcherPlatform.instance.getCallLogs();
  }

  static Future<void> clearCallLogs() {
    return CallWatcherPlatform.instance.clearCallLogs();
  }

  static Future<int?> initiateCall(String number) {
    return CallWatcherPlatform.instance.initiateCall(number);
  }

  /// Get call logs based on the query provided
  /// ```dart
  /// final query = LogQuery(
  ///  name: 'John Doe',
  ///  number: '1234567890',
  ///  isOutgoing: true,
  ///  dateFrom: DateTime.now().subtract(Duration(days: 7)),
  ///  dateTo: DateTime.now(),
  ///  durationFrom: 0,
  ///  durationTo: 100,
  /// );
  ///
  /// final logs = await CallWatcher.getQueryCallLogs(query);
  /// ```
  static Future<List<CallLogEntry>?> getQueryCallLogs(LogQuery query) {
    return CallWatcherPlatform.instance.getQueryCallLogs(query);
  }

  static Future<int?> endCurrentCall() {
    if (Platform.isIOS) {
      // INFO: ios platform doesn't support this feature
      return Future.value(null);
    }
    return CallWatcherPlatform.instance.endCurrentCall();
  }
}
