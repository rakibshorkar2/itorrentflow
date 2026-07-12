import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    guard let bridge = TorrentBridge.shared() else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    let channel = FlutterMethodChannel(
      name: "com.torrent.app/bridge",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [bridge] call, result in
      bridge.handle(call, result: result)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
