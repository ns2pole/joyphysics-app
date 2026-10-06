import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/experiment/magnetometer_baseline.dart';
import 'package:joyphysics/experiment/sensor_availability.dart';
import 'package:joyphysics/experiment/sensor_availability_types.dart';
import 'package:joyphysics/experiment/sensor_app_store_dialog.dart';
import 'package:joyphysics/experiment/sensor_gadget_l10n.dart';
import 'package:joyphysics/l10n/anim_ui.dart';
import 'package:joyphysics/l10n/app_localizations.dart';
import 'package:joyphysics/l10n/catalog_name_localizations.dart';
import 'package:joyphysics/shared_components.dart';

class MagnetometerExperimentWidget extends StatefulWidget with HasHeight {
  final double height;
  final bool useScaffold;

  /// When false (default), skip the startup baseline prompt.
  /// Embedded article gadgets keep absolute mode unless the user toggles.
  final bool promptBaselineOnStart;

  const MagnetometerExperimentWidget({
    Key? key,
    this.height = 320,
    this.useScaffold = true,
    this.promptBaselineOnStart = true,
  }) : super(key: key);

  @override
  double get widgetHeight => height;

  @override
  State<MagnetometerExperimentWidget> createState() =>
      _MagnetometerExperimentWidgetState();
}

class _MagnetometerExperimentWidgetState
    extends State<MagnetometerExperimentWidget> {
  StreamSubscription<MagnetometerEvent>? _subscription;
  double _x = 0, _y = 0, _z = 0;
  SensorAvailability _availability = SensorAvailability.checking;

  bool _useZeroBaseline = false;
  double _baselineX = 0, _baselineY = 0, _baselineZ = 0;
  bool _baselinePromptShown = false;

  @override
  void initState() {
    super.initState();
    _initSensor();
  }

  Future<void> _initSensor() async {
    final status = await checkSensorAvailability(SensorKind.magnetometer);
    if (!mounted) return;
    setState(() {
      _availability = status;
    });
    if (kIsWeb && widget.useScaffold) {
      if (status.state == SensorAvailabilityState.unavailable) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showSensorAppStoreDialog(context);
          }
        });
      }
    }
    if (status.isAvailable) {
      _startSubscription();
      _scheduleBaselinePrompt();
    }
  }

  void _scheduleBaselinePrompt() {
    if (!widget.promptBaselineOnStart || !widget.useScaffold) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeShowBaselinePrompt();
    });
  }

  Future<void> _maybeShowBaselinePrompt() async {
    if (_baselinePromptShown || !mounted) return;
    _baselinePromptShown = true;

    final useZero = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          animUi(
            ctx,
            ja: 'ゼロ基準にしますか？',
            en: 'Use zero baseline?',
          ),
        ),
        content: Text(
          animUi(
            ctx,
            ja:
                'スマホ内部の装置などの周辺環境の影響により、ある程度の大きさの磁場があらかじめ観測されることがあります。\n\n現状の磁場をゼロ基準にしますか？\n（あとからトグルでも切り替えできます）',
            en:
                'Due to the phone’s internal parts and surroundings, some magnetic field is often already present.\n\nSet the current field as the zero baseline?\n(You can also switch this later with the toggle.)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              animUi(ctx, ja: '絶対値のまま', en: 'Keep absolute'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              animUi(ctx, ja: 'ゼロ基準にする', en: 'Set zero baseline'),
            ),
          ),
        ],
      ),
    );

    if (!mounted || useZero == null) return;
    setState(() {
      if (useZero) {
        _captureBaseline();
        _useZeroBaseline = true;
      } else {
        _useZeroBaseline = false;
      }
    });
  }

  void _captureBaseline() {
    _baselineX = _x;
    _baselineY = _y;
    _baselineZ = _z;
  }

  void _onZeroBaselineToggle(bool enabled) {
    setState(() {
      if (enabled) {
        _captureBaseline();
        _useZeroBaseline = true;
      } else {
        _useZeroBaseline = false;
      }
    });
  }

  void _startSubscription() {
    _subscription?.cancel();
    _subscription = magnetometerEventStream().listen((event) {
      if (!mounted) return;
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
      });
    });
  }

  Future<void> _requestPermission() async {
    final status = await requestSensorPermission(SensorKind.magnetometer);
    if (!mounted) return;
    setState(() {
      _availability = status;
    });
    if (status.isAvailable) {
      _startSubscription();
      _scheduleBaselinePrompt();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = _availability.isAvailable;
    final needsPermission = _availability.needsPermission;
    final webStaticReadings = kIsWeb && !isAvailable && !needsPermission;
    final field = magnetometerDisplayField(
      rawX: _x,
      rawY: _y,
      rawZ: _z,
      useZeroBaseline: _useZeroBaseline,
      baselineX: _baselineX,
      baselineY: _baselineY,
      baselineZ: _baselineZ,
    );
    // Alerts follow the displayed magnitude (absolute or residual).
    final color = magnetometerAlertColor(field.magnitude);
    final warningText = magnetometerWarningText(context, field.magnitude);

    final content = SensorDisplayCard(
      title: animUi(
        context,
        ja: '現在の磁場強度',
        en: 'Current magnetic field',
      ),
      height: widget.height,
      children: (isAvailable || webStaticReadings)
          ? [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  animUi(
                    context,
                    ja: '起動時をゼロ基準',
                    en: 'Zero at current baseline',
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                subtitle: Text(
                  _useZeroBaseline
                      ? animUi(
                          context,
                          ja: '周辺影響を差し引いた相対値',
                          en: 'Relative to captured environment offset',
                        )
                      : animUi(
                          context,
                          ja: 'センサーの絶対値（μT）',
                          en: 'Sensor absolute values (μT)',
                        ),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                value: _useZeroBaseline,
                onChanged: _onZeroBaselineToggle,
              ),
              const SizedBox(height: 8),
              Text('X: ${field.x.toStringAsFixed(1)} μT',
                  style: const TextStyle(fontSize: 24, color: Colors.black)),
              Text('Y: ${field.y.toStringAsFixed(1)} μT',
                  style: const TextStyle(fontSize: 24, color: Colors.black)),
              Text('Z: ${field.z.toStringAsFixed(1)} μT',
                  style: const TextStyle(fontSize: 24, color: Colors.black)),
              const SizedBox(height: 24),
              Text(
                '${animUi(context, ja: '合成磁場', en: 'Resultant field')}: '
                '${field.magnitude.toStringAsFixed(1)} μT',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                warningText,
                style: TextStyle(fontSize: 16, color: color),
                textAlign: TextAlign.center,
              ),
            ]
          : [
              Text(
                sensorAvailabilityMessage(context, _availability),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              if (needsPermission)
                ElevatedButton(
                  onPressed: _requestPermission,
                  child: Text(AppLocalizations.of(context)!.allowSensorAccess),
                ),
            ],
    );

    if (!widget.useScaffold) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(localizeCatalogName(context, '磁気センサー')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: content,
    );
  }
}
