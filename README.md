# call_watcher
a flutter plugin to listen to call status, and mantain a call log, uses `CallKit` on iOS


### Usage on iOS
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

## Usage on Android
add these permissions to your `AndroidManifest.xml` in your app

```
  <uses-permission android:name="android.permission.CALL_PHONE" />
  <uses-permission android:name="android.permission.READ_CALL_LOG" />
  <!-- If you want to clear call log (Optional)  -->
  <uses-permission android:name="android.permission.WRITE_CALL_LOG" />
```

## TODO: 
- [x] Add Android Support
- [ ] Callback from native to flutter
