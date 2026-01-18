import 'package:flutter/material.dart';
import 'package:light/light.dart';
import 'dart:async';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/shared_components.dart';

class LuxMeasurementWidget extends StatefulWidget with HasHeight {
  final double height;
  final bool useScaffold;

  const LuxMeasurementWidget({
    Key? key,
    this.height = 400,
    this.useScaffold = true,
  }) : super(key: key);

  @override
  double get widgetHeight => height;

  @override
  _LuxMeasurementWidgetState createState() => _LuxMeasurementWidgetState();
}

class _LuxMeasurementWidgetState extends State<LuxMeasurementWidget> {
  Light _light = Light();
  StreamSubscription? _subscription;
  double? lux;

  @override
  void initState() {
    super.initState();
    _subscription = _light.lightSensorStream.listen((luxValue) {
      if (!mounted) return;
      setState(() {
        lux = luxValue.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = SensorDisplayCard(
      title: "現在の照度",
      height: widget.height,
      children: lux == null
          ? [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                "照度測定中...",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ]
          : [
              Text(
                "${lux!.toStringAsFixed(1)} lx",
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
    );

    if (!widget.useScaffold) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('光センサー'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: content,
    );
  }
}
