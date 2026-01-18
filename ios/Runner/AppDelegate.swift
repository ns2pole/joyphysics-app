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

    // センサーチェックチャネル
    let sensorCheckChannel = FlutterMethodChannel(name: "com.joyphysics/sensor_check", binaryMessenger: controller.binaryMessenger)
    sensorCheckChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "isSensorAvailable" {
        guard let args = call.arguments as? [String: Any],
              let sensorType = args["sensorType"] as? String else {
          result(false)
          return
        }
        
        let motionManager = CMMotionManager()
        switch sensorType {
        case "accelerometer":
          result(motionManager.isAccelerometerAvailable)
        case "barometer":
          result(CMAltimeter.isRelativeAltitudeAvailable())
        case "magnetometer":
          result(motionManager.isMagnetometerAvailable)
        case "light":
          result(false) // iOSでは一般的に取得不可
        case "microphone":
          // iOS端末は通常マイクを搭載している
          result(true)
        default:
          result(false)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // 周波数メソッドチャネル
    let frequencyChannel = FlutterMethodChannel(name: "com.joyphysics.frequency/mic", binaryMessenger: controller.binaryMessenger)
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

    fftTap = FFTTap(node: inputNode, bus: bus, bufferSize: 16384, format: inputFormat) { [weak self] frequency in
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
    private let bufferSize: UInt32
    private let node: AVAudioNode
    private let bus: AVAudioNodeBus
    private let window: [Float]
    private var isRunning = false
    private let callback: (Double) -> Void

    init(node: AVAudioNode,
         bus: AVAudioNodeBus,
         bufferSize: UInt32,
         format: AVAudioFormat,
         callback: @escaping (Double) -> Void) {

        self.node = node
        self.bus = bus
        self.bufferSize = bufferSize
        self.callback = callback

        log2n = UInt(round(log2(Float(bufferSize))))
        guard let setup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2)) else {
            fatalError("FFT setup failed")
        }
        fftSetup = setup

        // Hann窓
        window = vDSP.window(ofType: Float.self,
                             usingSequence: .hanningDenormalized,
                             count: Int(bufferSize),
                             isHalfWindow: false)

        node.installTap(onBus: bus, bufferSize: bufferSize, format: format) { [weak self] (buffer, _) in
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

        let frameLength = Int(buffer.frameLength)
        let expected = Int(bufferSize)
        if frameLength < expected { return }

        // 入力コピー
        let input = Array(UnsafeBufferPointer(start: channelData, count: expected))

        // 窓掛け
        var windowedSignal = [Float](repeating: 0, count: expected)
        vDSP_vmul(input, 1, window, 1, &windowedSignal, 1, vDSP_Length(expected))

        // 複素数バッファ準備
        let halfSize = expected / 2
        var realp = [Float](repeating: 0, count: halfSize)
        var imagp = [Float](repeating: 0, count: halfSize)
        var output = DSPSplitComplex(realp: &realp, imagp: &imagp)

        // 実数信号を分離複素数形式に変換
        windowedSignal.withUnsafeBufferPointer { pointer in
            pointer.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: halfSize) {
                vDSP_ctoz($0, 2, &output, 1, vDSP_Length(halfSize))
            }
        }

        // FFT実行
        vDSP_fft_zrip(fftSetup, &output, 1, log2n, FFTDirection(FFT_FORWARD))

        // スケーリング
        var scale: Float = 1.0 / Float(2 * expected)
        vDSP_vsmul(output.realp, 1, &scale, output.realp, 1, vDSP_Length(halfSize))
        vDSP_vsmul(output.imagp, 1, &scale, output.imagp, 1, vDSP_Length(halfSize))

        // 振幅²計算
        var mags = [Float](repeating: 0, count: halfSize)
        vDSP_zvmags(&output, 1, &mags, 1, vDSP_Length(halfSize))

        // 最大ピーク探索
        var maxMag: Float = 0
        var maxIndex: vDSP_Length = 0
        vDSP_maxvi(mags, 1, &maxMag, &maxIndex, vDSP_Length(halfSize))

        let k = Int(maxIndex)
        var refinedIndex = Double(k)

        // パラボラ補間（端は除外）
        if k > 0 && k < (halfSize - 1) {
            let alpha = Double(mags[k - 1])
            let beta  = Double(mags[k])
            let gamma = Double(mags[k + 1])
            let denom = (alpha - 2.0 * beta + gamma)
            if denom != 0 {
                let p = 0.5 * (alpha - gamma) / denom
                refinedIndex = Double(k) + p
            }
        }

        // 周波数計算
        let sampleRate = buffer.format.sampleRate
        let binWidth = sampleRate / Double(expected)
        let frequency = refinedIndex * binWidth

        callback(frequency)
    }
}
