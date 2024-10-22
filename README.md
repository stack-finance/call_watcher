# call_watcher
a flutter plugin to listen to incoming calls and outgoing calls, and mantain a call log, uses `CallKit` on iOS



### Usage on iOS
add these permissions to your `ios/Runner/Info.plist` in your app
```
    <key>NSUserActivityTypes</key>
	<array>
		<string>INStartAudioCallIntent</string>
	</array>
	<key>NSContactsUsageDescription</key>
	<string>This app requires access to your contacts to make calls.</string>
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>tel</string>
	</array>
```