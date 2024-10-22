import Flutter
import UIKit

public class CallWatcherPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "call_watcher", binaryMessenger: registrar.messenger())
    let instance = CallWatcherPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  private var callManager = CallManager() 

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    
    case "initiateCall":
      if let phoneNumber = call.arguments as? String {
        callManager.initiatePhoneCall(to: phoneNumber)
        result(0)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
      }
    
    case "getLastDialedNumber":
      if let lastDialedNumber = callManager.lastDialedNumber {
        result(lastDialedNumber)
      } else if let phoneNumber = callManager.callLog.first?.number {
        result(phoneNumber)
      } else {
        result(nil)
      } 
    case "getCallLog":
      result(callManager.callLog.map { $0.toMap() })

    case "clearCallLog":
      callManager.clearStorage()
      result(0)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
