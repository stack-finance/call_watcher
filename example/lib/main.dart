import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:call_watcher/call_watcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _lastCalledNumber = 'Unknown';
  final List<CallLogEntry> _callLogs = [];
  final TextEditingController _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getLastCalledNumber();
    WidgetsBinding.instance.addObserver(this);
  }

  // This method will be triggered for lifecycle changes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print("App is in the foreground (resumed)");
        _getCallLogs();
        break;
      case AppLifecycleState.inactive:
        print("App is inactive (e.g., incoming call or switching apps)");
        // App is in an inactive state, pause tasks here.
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initateCall(String number) async {
    int? result;
    try {
      result = await CallWatcher.initiateCall(number);
    } catch (e) {
      print(e);
    }

    if (!mounted) return;

    print(result);
    setState(() {
      _lastCalledNumber = number;
    });
  }

  Future<void> _getLastCalledNumber() async {
    String? lastCalledNumber;
    try {
      lastCalledNumber = await CallWatcher.getLastCalledNumber();
    } on PlatformException {
      lastCalledNumber = 'Failed to get last called number.';
    }

    if (!mounted) return;

    setState(() {
      _lastCalledNumber = lastCalledNumber ?? _lastCalledNumber;
    });
  }

  Future<void> _getCallLogs() async {
    List<CallLogEntry>? callLogs;
    try {
      callLogs = await CallWatcher.getCallLogs();
    } on PlatformException {
      callLogs = [];
    }

    if (!mounted) return;

    setState(() {
      _callLogs.clear();
      _callLogs.addAll(callLogs ?? []);
    });
  }

  double get bottomInset => MediaQuery.of(context).viewInsets.bottom;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        floatingActionButton: bottomInset == 0
            ? null
            : FloatingActionButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                },
                child: const Icon(Icons.keyboard_hide),
              ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Last called number: $_lastCalledNumber\n'),

                /// text box to enter the number to call
                /// and initiate the call
                ///

                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Enter the number to call',
                          ),
                          controller: _numberController,
                          keyboardType: TextInputType.phone,
                          onSubmitted: _initateCall,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _initateCall(_numberController.text);
                        },
                        icon: const Icon(CupertinoIcons.phone),
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _getLastCalledNumber,
                      child: const Text('Get Last Number'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: _getCallLogs,
                      child: const Text('Call Logs'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _callLogs.length,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_callLogs[index].number),
                                const SizedBox(width: 10),
                                Text(
                                    'Date: ${_callLogs[index].date?.formatDate}'),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Icon(
                                _callLogs[index].isOutgoing
                                    ? CupertinoIcons.phone_arrow_up_right
                                    : CupertinoIcons.phone_arrow_down_left,
                                color: _callLogs[index].isOutgoing
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              Text(
                                  '${_callLogs[index].duration?.inSeconds} sec'),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on DateTime {
  String get formatDate {
    final localDate = toLocal();
    return '${localDate.hour}:${localDate.minute} ${localDate.day}/${localDate.month}/${localDate.year}';
  }
}
