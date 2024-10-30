# call_watcher
a flutter plugin to listen to call status, and mantain a call log, uses `CallKit` on iOS


## Usage

```dart
import 'package:call_watcher/call_watcher.dart';


void initiateCall() async {
  try {
    await CallWatcher.initiateCall("1234567890");
  } catch (e) {
    print(e);
  }
}

void getCallLogs() {
  CallWatcher.getCallLogs().then((logs) {
    print(logs);
  }); 
}


void endCurrentCall() async {
  try {
    await CallWatcher.endCurrentCall();
  } catch (e) {
    print(e);
  }
}

void getLastCalledNumber() {
  CallWatcher.getLastCalledNumber().then((number) {
    print(number);
  });
}

final query = LogQuery(
    name: 'John Doe',
    number: '1234567890',
    isOutgoing: true,
    dateFrom: DateTime.now().subtract(Duration(days: 7)),
    dateTo: DateTime.now(),
    durationFrom: 0,
    durationTo: 100,
 );
 
final logs = await CallWatcher.getQueryCallLogs(query);

```

## Platform Specifics

### iOS
add these permissions to your `ios/Runner/Info.plist` in your app
```
<key>NSUserActivityTypes</key>
<array>
    <string>INStartAudioCallIntent</string>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tel</string>
</array>
```

### Usage on Android
add these permissions to your `AndroidManifest.xml` in your app

```
  <uses-permission android:name="android.permission.CALL_PHONE" />
  <uses-permission android:name="android.permission.READ_CALL_LOG" />
  <!-- If you want to clear call log (Optional)  -->
  <uses-permission android:name="android.permission.WRITE_CALL_LOG" />
```

## Pending: 
- [ ] Query call logs
- [ ] Callback from native to flutter
