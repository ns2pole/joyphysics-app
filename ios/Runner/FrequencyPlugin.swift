import Foundation
import AVFoundation
import Accelerate

class FrequencyPlugin: NSObject {
    private var engine: AVAudioEngine?
    private var frequency: Double = 0.0
    private let sampleRate: Double = 44100.0

    func start() {
        engine = AVAudioEngine()
        let inputNode = engine!.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, _ in
            self.frequency = self.analyzeFrequency(buffer: buffer)
        }

        try? engine?.start()
    }

    func stop() {
        engine?.stop()
        engine?.inputNode.removeTap(onBus: 0)
        engine = nil
    }

    func getFrequency() -> Double {
        return frequency
    }

    private func analyzeFrequency(buffer: AVAudioPCMBuffer) -> Double {
        guard let channelData = buffer.floatChannelData?[0] else { return 0.0 }
        let frameLength = Int(buffer.frameLength)
        var real = [Float](repeating: 0.0, count: frameLength)
        var imag = [Float](repeating: 0.0, count: frameLength)

        for i in 0..<frameLength {
            real[i] = channelData[i]
        }

        var splitComplex = DSPSplitComplex(realp: &real, imagp: &imag)
        let log2n = vDSP_Length(log2(Float(frameLength)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2)) else { return 0.0 }
        vDSP_fft_zip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))

        var magnitudes = [Float](repeating: 0.0, count: frameLength / 2)
        vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(frameLength / 2))

        var maxMag: Float = 0.0
        var maxIndex: vDSP_Length = 0
        vDSP_maxvi(magnitudes, 1, &maxMag, &maxIndex, vDSP_Length(frameLength / 2))

        vDSP_destroy_fftsetup(fftSetup)

        let freq = Double(maxIndex) * sampleRate / Double(frameLength)
        return freq
    }
}
