import 'package:call_watcher/call_watcher.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'call_watcher_method_channel.dart';

abstract class CallWatcherPlatform extends PlatformInterface {
  /// Constructs a CallWatcherPlatform.
  CallWatcherPlatform() : super(token: _token);

  static final Object _token = Object();

  static CallWatcherPlatform _instance = MethodChannelCallWatcher();

  /// The default instance of [CallWatcherPlatform] to use.
  ///
  /// Defaults to [MethodChannelCallWatcher].
  static CallWatcherPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CallWatcherPlatform] when
  /// they register themselves.
  static set instance(CallWatcherPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getLastCalledNumber();

  Future<List<CallLogEntry>?> getCallLogs();

  Future<void> clearCallLogs();

  Future<int?> initiateCall(String number);

  Future<Iterable<CallLogEntry>?> query(
      {DateTime? dateFrom,
      DateTime? dateTo,
      int? durationFrom,
      int? durationTo,
      bool? isOutgoing,
      String? number});
}
