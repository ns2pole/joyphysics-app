package com.joyphysics

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread
import org.jtransforms.fft.DoubleFFT_1D

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.joyphysics.frequency/mic"
    private val SENSOR_CHECK_CHANNEL = "com.joyphysics/sensor_check"
    private var analyzer: FrequencyAnalyzer? = null
    private var currentFrequency: Double = 0.0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SENSOR_CHECK_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isSensorAvailable" -> {
                    val sensorType = call.argument<String>("sensorType")
                    val sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
                    val available = when (sensorType) {
                        "accelerometer" -> sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) != null
                        "barometer" -> sensorManager.getDefaultSensor(Sensor.TYPE_PRESSURE) != null
                        "magnetometer" -> sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD) != null
                        "light" -> sensorManager.getDefaultSensor(Sensor.TYPE_LIGHT) != null
                        "microphone" -> packageManager.hasSystemFeature(PackageManager.FEATURE_MICROPHONE)
                        else -> false
                    }
                    result.success(available)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    if (analyzer == null) {
                        analyzer = FrequencyAnalyzer(
                            callback = { freq ->
                                currentFrequency = freq
                            }
                        )
                    }
                    try {
                        analyzer?.start()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.localizedMessage, null)
                    }
                }
                "stop" -> {
                    try {
                        analyzer?.stop()
                        analyzer = null
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.localizedMessage, null)
                    }
                }
                "getFrequency" -> {
                    result.success(currentFrequency)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

class FrequencyAnalyzer(
    private val callback: (Double) -> Unit,
    private val sampleRate: Int = 44100,
    private val bufferSize: Int = 16384
) {
    private var audioRecord: AudioRecord? = null
    @Volatile
    private var isRecording = false
    private val fft = DoubleFFT_1D(bufferSize.toLong())
    private val mainHandler = Handler(Looper.getMainLooper())

    // Hann窓関数
    private val hannWindow = DoubleArray(bufferSize) { i ->
        0.5 - 0.5 * kotlin.math.cos(2.0 * Math.PI * i / (bufferSize - 1))
    }

    fun start() {
        val minBufferSize = AudioRecord.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        if (minBufferSize == AudioRecord.ERROR || minBufferSize == AudioRecord.ERROR_BAD_VALUE) {
            throw IllegalStateException("Invalid minBufferSize")
        }
        val actualBufferSize = if (bufferSize < minBufferSize) minBufferSize else bufferSize

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            actualBufferSize * 2
        )

        if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
            throw IllegalStateException("AudioRecord initialization failed")
        }

        audioRecord?.startRecording()
        isRecording = true

        thread {
            val buffer = ShortArray(bufferSize)
            val fftBuffer = DoubleArray(bufferSize * 2) // 実部・虚部用
            val mags = DoubleArray(bufferSize / 2)

            while (isRecording) {
                val read = audioRecord!!.read(buffer, 0, bufferSize)
                if (read > 0) {
                    for (i in 0 until bufferSize) {
                        val sample = buffer[i].toDouble() / Short.MAX_VALUE
                        fftBuffer[2 * i] = sample * hannWindow[i]
                        fftBuffer[2 * i + 1] = 0.0
                    }

                    fft.complexForward(fftBuffer)

                    for (i in mags.indices) {
                        val re = fftBuffer[2 * i]
                        val im = fftBuffer[2 * i + 1]
                        mags[i] = re * re + im * im
                    }

                    // 最大ピーク検出
                    var maxIndex = 0
                    var maxMag = mags[0]
                    for (i in 1 until mags.size) {
                        if (mags[i] > maxMag) {
                            maxMag = mags[i]
                            maxIndex = i
                        }
                    }

                    // パラボラ補間
                    var refinedIndex = maxIndex.toDouble()
                    if (maxIndex > 0 && maxIndex < mags.size - 1) {
                        val alpha = mags[maxIndex - 1]
                        val beta = mags[maxIndex]
                        val gamma = mags[maxIndex + 1]
                        val denom = alpha - 2 * beta + gamma
                        if (denom != 0.0) {
                            val p = 0.5 * (alpha - gamma) / denom
                            refinedIndex += p
                        }
                    }

                    val frequency = refinedIndex * sampleRate / bufferSize

                    mainHandler.post {
                        callback(frequency)
                    }
                }
            }
        }
    }

    fun stop() {
        isRecording = false
        try {
            audioRecord?.stop()
        } catch (e: IllegalStateException) {
            // ignore
        }
        audioRecord?.release()
        audioRecord = null
    }
}
