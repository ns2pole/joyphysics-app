import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:google_fonts/google_fonts.dart'; // 等幅フォント
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/experiment/sensor_availability.dart';
import 'package:joyphysics/experiment/sensor_availability_types.dart';
import 'package:joyphysics/experiment/sensor_app_store_dialog.dart';
import 'package:joyphysics/shared_components.dart';

class GyroscopeExperimentWidget extends StatefulWidget with HasHeight {
  final double height;
  final bool useScaffold;

  const GyroscopeExperimentWidget({
    Key? key,
    this.height = 400,
    this.useScaffold = true,
  }) : super(key: key);

  @override
  double get widgetHeight => height;

  @override
  State<GyroscopeExperimentWidget> createState() =>
      _GyroscopeExperimentWidgetState();
}

class _GyroscopeExperimentWidgetState extends State<GyroscopeExperimentWidget> {
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  StreamSubscription<GyroscopeEvent>? _subscription;
  SensorAvailability _availability = SensorAvailability.checking;

  @override
  void initState() {
    super.initState();
    _initSensor();
  }

  Future<void> _initSensor() async {
    final status = await checkSensorAvailability(SensorKind.gyroscope);
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
    }
  }

  void _startSubscription() {
    _subscription?.cancel();
    _subscription = gyroscopeEventStream().listen((event) {
      if (!mounted) return;
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
      });
    }, onError: (_) {
      if (!mounted) return;
      setState(() {
        _availability = SensorAvailability.unavailable;
      });
    }, cancelOnError: true);
  }

  Future<void> _requestPermission() async {
    final status = await requestSensorPermission(SensorKind.gyroscope);
    if (!mounted) return;
    setState(() {
      _availability = status;
    });
    if (status.isAvailable) {
      _startSubscription();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // 桁数を固定して揺れ防止
  String formatValue(double v) => v.toStringAsFixed(2).padLeft(6, ' ');

  // 桁数を固定して揺れ防止
  String formatValueMag(double v) => v.toStringAsFixed(2).padLeft(0, ' ');

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = _availability.isAvailable;
    final bool needsPermission = _availability.needsPermission;
    final bool webStaticReadings = kIsWeb && !isAvailable && !needsPermission;
    final magnitude = sqrt(x * x + y * y + z * z);

    final content = SensorDisplayCard(
      title: 'ジャイロセンサーの値',
      height: widget.height,
      children: (isAvailable || webStaticReadings)
          ? [
              Text("X: ${formatValue(x)} (rad/s)",
                  style:
                      GoogleFonts.robotoMono(fontSize: 22, color: Colors.black)),
              Text("Y: ${formatValue(y)} (rad/s)",
                  style:
                      GoogleFonts.robotoMono(fontSize: 22, color: Colors.black)),
              Text("Z: ${formatValue(z)} (rad/s)",
                  style:
                      GoogleFonts.robotoMono(fontSize: 22, color: Colors.black)),
              const SizedBox(height: 24),
              const Text(
                "合成角速度",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${formatValueMag(magnitude)} rad/s",
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ]
          : [
              Text(
                _availability.message,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              if (needsPermission)
                ElevatedButton(
                  onPressed: _requestPermission,
                  child: const Text('センサー利用を許可'),
                ),
            ],
    );

    if (!widget.useScaffold) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ジャイロセンサー'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: content,
    );
  }
}
