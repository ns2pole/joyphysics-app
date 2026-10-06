import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/experiment/sensor_app_store_dialog.dart';
import 'package:joyphysics/l10n/anim_ui.dart';
import 'package:joyphysics/l10n/catalog_name_localizations.dart';
import 'package:joyphysics/shared_components.dart';

class FrequencyMeasureWidget extends StatefulWidget with HasHeight {
  final double height;
  final bool useScaffold;

  const FrequencyMeasureWidget({
    Key? key,
    this.height = 320,
    this.useScaffold = true,
  }) : super(key: key);

  @override
  double get widgetHeight => height;

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
    if (kIsWeb) {
      setState(() {
        _frequency = 0.0;
      });
      if (widget.useScaffold) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showSensorAppStoreDialog(
              context,
              title: animUi(
                context,
                ja: '周波数測定はアプリ版で',
                en: 'Frequency measurement is available in the app',
              ),
              message: animUi(
                context,
                ja: 'Web版ではマイクからの本番測定に対応していません。アプリをインストールしてフル体験してください。',
                en:
                    'Full microphone measurement is not available on the web. Install the app for the full experience.',
              ),
            );
          }
        });
      }
      return;
    }
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
        title: Text(
          animUi(
            context,
            ja: 'マイク権限が必要です',
            en: 'Microphone permission required',
          ),
        ),
        content: Text(
          animUi(
            context,
            ja: 'この機能を使うためにはマイクの権限が必要です。権限を許可してください。',
            en:
                'This feature needs microphone permission. Please allow access.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkPermissionAndStartMic();
            },
            child: Text(animUi(context, ja: '再試行', en: 'Try again')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(animUi(context, ja: 'キャンセル', en: 'Cancel')),
          ),
        ],
      ),
    );
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          animUi(
            context,
            ja: 'マイク権限が永久に拒否されています',
            en: 'Microphone permission permanently denied',
          ),
        ),
        content: Text(
          animUi(
            context,
            ja: '権限を手動で設定アプリから許可してください。',
            en: 'Please allow permission manually in Settings.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text(animUi(context, ja: '設定を開く', en: 'Open Settings')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(animUi(context, ja: 'キャンセル', en: 'Cancel')),
          ),
        ],
      ),
    );
  }

  Future<void> _startMic() async {
    try {
      await _frequencyChannel.invokeMethod('start');
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
        if (!mounted) return;
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
    if (kIsWeb) {
      super.dispose();
      return;
    }
    _timer?.cancel();
    _frequencyChannel.invokeMethod('stop');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = SensorDisplayCard(
      title: animUi(
        context,
        ja: '現在の周波数',
        en: 'Current frequency',
      ),
      height: widget.height,
      children: _frequency == null
          ? [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                animUi(
                  context,
                  ja: '周波数計測中...',
                  en: 'Measuring frequency…',
                ),
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ]
          : [
              Text(
                "${_frequency!.toStringAsFixed(1)} Hz",
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
    );

    if (!widget.useScaffold) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(localizeCatalogName(context, '周波数センサー')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: content,
    );
  }
}
