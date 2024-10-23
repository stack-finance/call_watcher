import 'package:call_watcher/models/call_log.dart';

import 'call_watcher_platform_interface.dart';
export 'models/call_log.dart';

class CallWatcher {
  Future<String?> getLastCalledNumber() {
    return CallWatcherPlatform.instance.getLastCalledNumber();
  }

  Future<List<CallLogEntry>?> getCallLogs() {
    return CallWatcherPlatform.instance.getCallLogs();
  }

  Future<Iterable<CallLogEntry>?> query({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? durationFrom,
    int? durationTo,
    bool? isOutgoing,
    String? number
  }){
    return CallWatcherPlatform.instance.query(
      dateFrom: dateFrom,
      dateTo: dateTo,
      durationFrom: durationFrom,
      durationTo: durationTo,
      isOutgoing: isOutgoing,
      number: number
    );
  }

  Future<void> clearCallLogs() {
    return CallWatcherPlatform.instance.clearCallLogs();
  }

  Future<int?> initiateCall(String number) {
    return CallWatcherPlatform.instance.initiateCall(number);
  }
}


