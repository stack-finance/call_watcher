import 'package:call_watcher/call_watcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'call_watcher_platform_interface.dart';

/// An implementation of [CallWatcherPlatform] that uses method channels.
class MethodChannelCallWatcher implements CallWatcherPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('call_watcher');

  @override
  Future<void> clearCallLogs() {
    return methodChannel.invokeMapMethod('clearCallLog');
  }

  @override
  Future<List<CallLogEntry>?> getCallLogs() async {
    final logs =
        (await methodChannel.invokeListMethod<Map>('getCallLog')) as List<Map>;

    /// cast the list of maps to a list of CallLogEntry objects
    return logs.map((log) => CallLogEntry.fromJson(log)).toList();
  }

  @override
  Future<String?> getLastCalledNumber() {
    return methodChannel.invokeMethod<String>('getLastDialedNumber');
  }

  @override
  Future<int?> initiateCall(String number) {
    return methodChannel.invokeMethod<int>('initiateCall', number);
  }


  @override
  Future<Iterable<CallLogEntry>?> query({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? durationFrom,
    int? durationTo,
    bool? isOutgoing,
    String? number,
  }) async {
    final logs = (await methodChannel.invokeListMethod<Map>(
      'query',
      {
        'dateFrom': dateFrom?.millisecondsSinceEpoch,
        'dateTo': dateTo?.millisecondsSinceEpoch,
        'durationFrom': durationFrom,
        'durationTo': durationTo,
        'isOutgoing': isOutgoing,
        'number': number,
      },
    )) as List<Map>;

    return logs.map((log) => CallLogEntry.fromJson(log)).toList();
  }
}
