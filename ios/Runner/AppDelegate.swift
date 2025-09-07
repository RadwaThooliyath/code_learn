import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // Security method channel for screenshot prevention
    let screenshotChannel = FlutterMethodChannel(name: "com.uptrail.security/screenshot", binaryMessenger: controller.binaryMessenger)
    screenshotChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "preventScreenshots" {
        self.preventScreenshots()
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    // Screen recording detection method channel
    let recordingChannel = FlutterMethodChannel(name: "com.uptrail.security/recording", binaryMessenger: controller.binaryMessenger)
    recordingChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "isScreenRecording" {
        result(UIScreen.main.isCaptured)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func preventScreenshots() {
    guard let window = self.window else { return }
    
    // Create a security view to prevent screenshots
    let securityView = UIView(frame: window.bounds)
    securityView.backgroundColor = UIColor.black
    securityView.isHidden = true
    securityView.tag = 999999
    
    window.addSubview(securityView)
    
    // Listen for screenshot notifications
    NotificationCenter.default.addObserver(
      forName: UIApplication.userDidTakeScreenshotNotification,
      object: nil,
      queue: .main) { _ in
        // Screenshot was taken - we can't prevent it but we can detect it
        print("🚨 SECURITY ALERT: Screenshot taken on iOS!")
      }
    
    // Listen for screen recording changes
    NotificationCenter.default.addObserver(
      forName: UIScreen.capturedDidChangeNotification,
      object: nil,
      queue: .main) { _ in
        if UIScreen.main.isCaptured {
          // Show security overlay when screen recording starts
          securityView.isHidden = false
          print("🚨 SECURITY ALERT: Screen recording started!")
        } else {
          // Hide security overlay when screen recording stops
          securityView.isHidden = true
          print("✅ Screen recording stopped")
        }
      }
  }
}
