import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class FrequencyMeasureWidget extends StatefulWidget {
  final double height;

  const FrequencyMeasureWidget({Key? key, this.height = 400}) : super(key: key);

  @override
  State<FrequencyMeasureWidget> createState() => _FrequencyMeasureWidgetState();
}

class _FrequencyMeasureWidgetState extends State<FrequencyMeasureWidget> {
  static const _frequencyChannel = MethodChannel('com.joyphysics.frequency/mic');

  double? _frequency;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndStartMic();
  }

  Future<void> _checkPermissionAndStartMic() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      _startMic();
    } else if (status.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        _startMic();
      } else {
        _showPermissionDeniedDialog();
      }
    } else if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('マイク権限が必要です'),
        content: const Text('この機能を使うためにはマイクの権限が必要です。権限を許可してください。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkPermissionAndStartMic();
            },
            child: const Text('再試行'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('マイク権限が永久に拒否されています'),
        content: const Text('権限を手動で設定アプリから許可してください。'),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('設定を開く'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  Future<void> _startMic() async {
    try {
      await _frequencyChannel.invokeMethod('start');
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
        final freq = await _frequencyChannel.invokeMethod('getFrequency');
        setState(() {
          _frequency = (freq as double?) ?? 0.0;
        });
      });
    } on PlatformException catch (e) {
      print('Failed to start mic: ${e.message}');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _frequencyChannel.invokeMethod('stop');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // ←背景を白に設定
      height: widget.height,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(12),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: _frequency == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "周波数計測中...",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "現在の周波数",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "${_frequency!.toStringAsFixed(1)} Hz",
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
