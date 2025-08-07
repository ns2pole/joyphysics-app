import UIKit
import Flutter
import CoreMotion

@main
@objc class AppDelegate: FlutterAppDelegate {
  let altimeter = CMAltimeter()
  var barometerEventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let barometerChannel = FlutterEventChannel(name: "barometer_channel", binaryMessenger: controller.binaryMessenger)

    barometerChannel.setStreamHandler(self)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// MARK: - FlutterStreamHandler
extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    if CMAltimeter.isRelativeAltitudeAvailable() {
      barometerEventSink = events
      altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { data, error in
        if let pressure = data?.pressure.doubleValue {
          let hPa = pressure * 10.0  // kPa → hPa
          events(hPa)
        }
      }
    } else {
      return FlutterError(code: "UNAVAILABLE", message: "Altimeter not available", details: nil)
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    altimeter.stopRelativeAltitudeUpdates()
    barometerEventSink = nil
    return nil
  }
}
