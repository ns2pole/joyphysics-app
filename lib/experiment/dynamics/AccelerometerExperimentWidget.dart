import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:google_fonts/google_fonts.dart'; // 等幅フォント
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/shared_components.dart';

class AccelerometerExperimentWidget extends StatefulWidget with HasHeight {
  final double height;
  final bool useScaffold;

  const AccelerometerExperimentWidget({
    Key? key,
    this.height = 400,
    this.useScaffold = true,
  }) : super(key: key);

  @override
  double get widgetHeight => height;

  @override
  State<AccelerometerExperimentWidget> createState() => _AccelerometerExperimentWidgetState();
}

class _AccelerometerExperimentWidgetState extends State<AccelerometerExperimentWidget> {
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  StreamSubscription<UserAccelerometerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = userAccelerometerEvents.listen((event) {
      if (!mounted) return;
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
      });
    });
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
    final magnitude = sqrt(x * x + y * y + z * z);

    final content = SensorDisplayCard(
      title: '加速度センサーの値',
      height: widget.height,
      children: [
        Text("X: ${formatValue(x)} (m/s²)",
            style: GoogleFonts.robotoMono(fontSize: 22, color: Colors.black)),
        Text("Y: ${formatValue(y)} (m/s²)",
            style: GoogleFonts.robotoMono(fontSize: 22, color: Colors.black)),
        Text("Z: ${formatValue(z)} (m/s²)",
            style: GoogleFonts.robotoMono(fontSize: 22, color: Colors.black)),
        const SizedBox(height: 24),
        const Text(
          "合成加速度",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${formatValueMag(magnitude)} m/s²",
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoMono(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );

    if (!widget.useScaffold) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('加速度センサー'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: content,
    );
  }
}
