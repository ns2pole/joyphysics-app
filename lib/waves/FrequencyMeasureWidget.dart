import 'package:flutter/material.dart';
import 'package:waveform_fft/waveform_fft.dart';
import 'package:permission_handler/permission_handler.dart';

class FrequencyMeasureWidget extends StatefulWidget {
  const FrequencyMeasureWidget({Key? key}) : super(key: key);

  @override
  State<FrequencyMeasureWidget> createState() => _FrequencyMeasureWidgetState();
}

class _FrequencyMeasureWidgetState extends State<FrequencyMeasureWidget> {
  final AudioCaptureService _audioCapture = AudioCaptureService();

  bool _isRecording = false;
  double? _peakFrequency;

  static const double sampleRate = 44100.0;
  static const int fftSize = 1024; // FFTサイズは必要に応じて調整

Future<bool> _requestMicPermission() async {
  var status = await Permission.microphone.status;

  if (status.isDenied || status.isRestricted) {
    status = await Permission.microphone.request();
  }

  if (status.isPermanentlyDenied) {
    // 永久拒否状態 → ダイアログで案内
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('マイクの権限が必要です'),
        content: const Text(
          'この機能を使うにはマイクのアクセスを有効にする必要があります。'
          '設定アプリで権限を許可してください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings(); // 設定アプリを開く
            },
            child: const Text('設定を開く'),
          ),
        ],
      ),
    );
    return false;
  }

  return status.isGranted;
}

  // 周波数データ処理
  void _processFrequencyData(
      List<({FrequencySpectrum spectrum, double value})> data) {
    if (data.isEmpty) return;

    // 最大ピークのインデックスを探す
    int peakIndex = 0;
    double peakValue = double.negativeInfinity;
    for (int i = 0; i < data.length; i++) {
      if (data[i].value > peakValue) {
        peakValue = data[i].value;
        peakIndex = i;
      }
    }

    // 周波数計算
    final freq = peakIndex * (sampleRate / fftSize);

    setState(() {
      _peakFrequency = freq;
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _audioCapture.stopCapture();
    } else {
      if (!await _requestMicPermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('マイク権限が許可されていません')),
        );
        return;
      }
      await _audioCapture.startCapture(
        (freqData) => _processFrequencyData(freqData),
      );
    }
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  @override
  void dispose() {
    _audioCapture.stopCapture();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "周波数測定",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Text(
                  _peakFrequency != null
                      ? "ピーク周波数: ${_peakFrequency!.toStringAsFixed(1)} Hz"
                      : "計測中...",
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _toggleRecording,
                  child: Text(_isRecording ? '停止' : '開始'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
