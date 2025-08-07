import 'package:flutter/material.dart';
import 'package:light/light.dart';

class LightSensorWidget extends StatefulWidget {
  @override
  _LightSensorWidgetState createState() => _LightSensorWidgetState();
}

class _LightSensorWidgetState extends State<LightSensorWidget> {
  Light _light = Light();
  double? lux;
  StreamSubscription<int>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _light.lightSensorStream.listen((int luxValue) {
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
    return Center(
      child: Text(
        lux == null ? '明るさ取得中...' : '明るさ: ${lux!.toStringAsFixed(1)} lx',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
