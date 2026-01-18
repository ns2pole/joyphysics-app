import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/shared_components.dart';

class MagnetometerExperimentWidget extends StatefulWidget with HasHeight {
  final double height;
  final bool useScaffold;

  const MagnetometerExperimentWidget({
    Key? key,
    this.height = 400,
    this.useScaffold = true,
  }) : super(key: key);

  @override
  double get widgetHeight => height;

  @override
  State<MagnetometerExperimentWidget> createState() => _MagnetometerExperimentWidgetState();
}

class _MagnetometerExperimentWidgetState extends State<MagnetometerExperimentWidget> {
  StreamSubscription<MagnetometerEvent>? _subscription;
  double _x = 0, _y = 0, _z = 0;

  @override
  void initState() {
    super.initState();
    _subscription = magnetometerEventStream().listen((event) {
      if (!mounted) return;
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
      });
    });
  }

  Color getColorByMagnitude(double mag) {
    if (mag < 200) return Colors.green;
    if (mag < 500) return Colors.yellow.shade700;
    if (mag < 2000) return Colors.orange;
    return Colors.red;
  }

  String getWarningText(double mag) {
    if (mag < 200) return "磁場は正常範囲内です。";
    if (mag < 500) return "やや強い磁場を検知しています。";
    if (mag < 2000) return "強力な磁場です。";
    return "非常に強い磁場です！端末への影響にご注意ください。";
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final magnitude = sqrt(_x * _x + _y * _y + _z * _z);
    final color = getColorByMagnitude(magnitude);
    final warningText = getWarningText(magnitude);

    final content = SensorDisplayCard(
      title: "現在の磁場強度",
      height: widget.height,
      children: [
        Text("X: ${_x.toStringAsFixed(1)} μT",
            style: const TextStyle(fontSize: 24, color: Colors.black)),
        Text("Y: ${_y.toStringAsFixed(1)} μT",
            style: const TextStyle(fontSize: 24, color: Colors.black)),
        Text("Z: ${_z.toStringAsFixed(1)} μT",
            style: const TextStyle(fontSize: 24, color: Colors.black)),
        const SizedBox(height: 24),
        Text(
          "合成磁場: ${magnitude.toStringAsFixed(1)} μT",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color),
        ),
        const SizedBox(height: 12),
        Text(
          warningText,
          style: TextStyle(fontSize: 16, color: color),
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
        title: const Text('磁気センサー'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: content,
    );
  }
}
