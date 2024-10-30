import 'dart:io';

import 'package:call_watcher/models/call_log.dart';
import 'package:call_watcher/models/log_query.dart';

import 'call_watcher_platform_interface.dart';
export 'models/models.dart';

class CallWatcher {
  static Future<String?> getLastCalledNumber() {
    return CallWatcherPlatform.instance.getLastCalledNumber();
  }

  static Future<List<CallLogEntry>?> getCallLogs() {
    return CallWatcherPlatform.instance.getCallLogs();
  }

  static Future<void> clearCallLogs() {
    return CallWatcherPlatform.instance.clearCallLogs();
  }

  static Future<int?> initiateCall(String number) {
    return CallWatcherPlatform.instance.initiateCall(number);
  }

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
