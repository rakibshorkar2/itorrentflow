import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  static var pendingMagnetURL: String?

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
      if call.method == "getPendingMagnetURL" {
        result(AppDelegate.pendingMagnetURL)
        AppDelegate.pendingMagnetURL = nil
      } else {
        bridge.handle(call, result: result)
      }
    }

    if let url = launchOptions?[.url] as? URL {
      AppDelegate.pendingMagnetURL = url.absoluteString
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if url.scheme == "magnet" {
      AppDelegate.pendingMagnetURL = url.absoluteString
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
