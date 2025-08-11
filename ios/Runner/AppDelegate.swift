import UIKit
import Flutter
import CoreMotion
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  // 気圧関連
  let altimeter = CMAltimeter()
  var barometerEventSink: FlutterEventSink?

  // 周波数関連
  var audioEngine: AVAudioEngine?
  var fftTap: FFTTap?
  var currentFrequency: Double = 0.0

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController

    // 気圧イベントチャネル
    let barometerChannel = FlutterEventChannel(name: "barometer_channel", binaryMessenger: controller.binaryMessenger)
    barometerChannel.setStreamHandler(self)

    // 周波数メソッドチャネル
    let frequencyChannel = FlutterMethodChannel(name: "com.example.frequency/mic", binaryMessenger: controller.binaryMessenger)
    frequencyChannel.setMethodCallHandler(handleFrequencyMethodCall)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 周波数のメソッド呼び出し処理
  private func handleFrequencyMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "start":
      startMic(result: result)
    case "stop":
      stopMic()
      result(nil)
    case "getFrequency":
      result(currentFrequency)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func startMic(result: FlutterResult) {
    audioEngine = AVAudioEngine()

    guard let engine = audioEngine else {
      result(FlutterError(code: "AUDIO_ENGINE_ERROR", message: "AudioEngine init failed", details: nil))
      return
    }

    let inputNode = engine.inputNode
    let bus = 0

    let inputFormat = inputNode.inputFormat(forBus: bus)

    fftTap = FFTTap(node: inputNode, bus: bus, bufferSize: 1024, format: inputFormat) { [weak self] frequency in
      DispatchQueue.main.async {
        self?.currentFrequency = frequency
      }
    }

    fftTap?.start()

    do {
      try engine.start()
      result(nil)
    } catch {
      result(FlutterError(code: "AUDIO_ENGINE_START_FAILED", message: error.localizedDescription, details: nil))
    }
  }

  private func stopMic() {
    fftTap?.stop()
    fftTap = nil

    audioEngine?.stop()
    audioEngine = nil
  }
}

// MARK: - FlutterStreamHandler for Barometer

extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    if CMAltimeter.isRelativeAltitudeAvailable() {
      barometerEventSink = events
      altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { data, error in
        if let pressure = data?.pressure.doubleValue {
          let hPa = pressure * 10.0
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


import AVFoundation
import Accelerate

class FFTTap {
  private let fftSetup: FFTSetup
  private let log2n: UInt
  private var bufferSize: UInt32
  private let node: AVAudioNode
  private let bus: AVAudioNodeBus
  private let bufferSizeFrames: UInt32
  private let window: [Float]
  private var fftInputReal: [Float]
  private var fftInputImaginary: [Float]

  private var callback: (Double) -> Void
  private var isRunning = false

  init(node: AVAudioNode, bus: AVAudioNodeBus, bufferSize: UInt32, format: AVAudioFormat, callback: @escaping (Double) -> Void) {
    self.node = node
    self.bus = bus
    self.bufferSize = bufferSize
    self.bufferSizeFrames = bufferSize
    self.callback = callback

    log2n = UInt(round(log2(Float(bufferSize))))
    fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))!

    window = vDSP.window(ofType: Float.self, usingSequence: .hanningDenormalized, count: Int(bufferSize), isHalfWindow: false)
    fftInputReal = [Float](repeating: 0, count: Int(bufferSize/2))
    fftInputImaginary = [Float](repeating: 0, count: Int(bufferSize/2))

    node.installTap(onBus: bus, bufferSize: bufferSize, format: format) { [weak self] (buffer, when) in
      self?.processBuffer(buffer: buffer)
    }
  }

  func start() {
    isRunning = true
  }

  func stop() {
    isRunning = false
    node.removeTap(onBus: bus)
    vDSP_destroy_fftsetup(fftSetup)
  }

  private func processBuffer(buffer: AVAudioPCMBuffer) {
    guard isRunning else { return }
    guard let channelData = buffer.floatChannelData?[0] else { return }

    // Apply window
    var windowedSignal = [Float](repeating: 0, count: Int(bufferSize))
    vDSP_vmul(channelData, 1, window, 1, &windowedSignal, 1, vDSP_Length(bufferSize))

    // Prepare split complex buffer
    var realp = [Float](repeating: 0, count: Int(bufferSize / 2))
    var imagp = [Float](repeating: 0, count: Int(bufferSize / 2))
    var output = DSPSplitComplex(realp: &realp, imagp: &imagp)

    // Convert to split complex format
    windowedSignal.withUnsafeBufferPointer { pointer in
      pointer.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: Int(bufferSize / 2)) { typeConvertedTransferBuffer in
        vDSP_ctoz(typeConvertedTransferBuffer, 2, &output, 1, vDSP_Length(bufferSize / 2))
      }
    }

    // FFT
    vDSP_fft_zrip(fftSetup, &output, 1, log2n, FFTDirection(FFT_FORWARD))

    // Magnitude calculation
    var magnitudes = [Float](repeating: 0.0, count: Int(bufferSize / 2))
    vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(bufferSize / 2))

    // Find max magnitude index
    var maxMag: Float = 0
    var maxIndex: vDSP_Length = 0
    vDSP_maxvi(magnitudes, 1, &maxMag, &maxIndex, vDSP_Length(bufferSize / 2))

    // Calculate frequency
    let sampleRate = buffer.format.sampleRate
    let frequency = Double(maxIndex) * sampleRate / Double(bufferSize)

    callback(frequency)
  }
}
