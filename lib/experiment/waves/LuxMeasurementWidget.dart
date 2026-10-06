import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:light/light.dart';
import 'dart:async';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/experiment/sensor_app_store_dialog.dart';
import 'package:joyphysics/l10n/anim_ui.dart';
import 'package:joyphysics/l10n/catalog_name_localizations.dart';
import 'package:joyphysics/shared_components.dart';

class LuxMeasurementWidget extends StatefulWidget with HasHeight {
  final double height;
  final bool useScaffold;

  const LuxMeasurementWidget({
    Key? key,
    this.height = 320,
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
    if (kIsWeb) {
      setState(() {
        lux = 0.0;
      });
      if (widget.useScaffold) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showSensorAppStoreDialog(
              context,
              title: animUi(
                context,
                ja: '光センサーはアプリ版で',
                en: 'Light sensor is available in the app',
              ),
              message: animUi(
                context,
                ja: 'Web版では照度の本番測定に対応していません。アプリをインストールしてフル体験してください。',
                en:
                    'Full illuminance measurement is not available on the web. Install the app for the full experience.',
              ),
            );
          }
        });
      }
      return;
    }
    _subscription = _light.lightSensorStream.listen((luxValue) {
      if (!mounted) return;
      setState(() {
        lux = luxValue.toDouble();
      });
    });
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _subscription?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = SensorDisplayCard(
      title: animUi(
        context,
        ja: '現在の照度',
        en: 'Current illuminance',
      ),
      height: widget.height,
      children: lux == null
          ? [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                animUi(
                  context,
                  ja: '照度測定中...',
                  en: 'Measuring illuminance…',
                ),
                style: const TextStyle(fontSize: 18, color: Colors.black),
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
        title: Text(localizeCatalogName(context, '光センサー')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: content,
    );
  }
}
