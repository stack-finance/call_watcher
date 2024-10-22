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

## TODO: 
- [ ] Add Android Support
- [ ] Callback from native to flutter