import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/experiment/sensor_availability.dart';
import 'package:joyphysics/experiment/sensor_availability_types.dart';
import 'package:joyphysics/experiment/sensor_app_store_dialog.dart';
import 'package:joyphysics/experiment/sensor_gadget_l10n.dart';
import 'package:joyphysics/l10n/anim_ui.dart';
import 'package:joyphysics/l10n/app_localizations.dart';
import 'package:joyphysics/l10n/catalog_name_localizations.dart';
import 'package:joyphysics/shared_components.dart';

class BarometerExperimentWidget extends StatefulWidget with HasHeight {
  final double height;
  final bool useScaffold;

  const BarometerExperimentWidget({
    Key? key,
    this.height = 320,
    this.useScaffold = true,
  }) : super(key: key);

  @override
  double get widgetHeight => height;

  @override
  State<BarometerExperimentWidget> createState() => _BarometerExperimentWidgetState();
}

class _BarometerExperimentWidgetState extends State<BarometerExperimentWidget> {
  double? _pressure;
  StreamSubscription<BarometerEvent>? _pressureSub;
  SensorAvailability _availability = SensorAvailability.checking;

  @override
  void initState() {
    super.initState();
    _initSensor();
  }

  Future<void> _initSensor() async {
    final status = await checkSensorAvailability(SensorKind.barometer);
    if (!mounted) return;
    setState(() {
      _availability = status;
    });
    if (kIsWeb && widget.useScaffold) {
      if (!status.isAvailable && !status.needsPermission) {
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
    _pressureSub?.cancel();
    _pressureSub = barometerEventStream().listen((BarometerEvent event) {
      if (!mounted) return;
      setState(() {
        _pressure = event.pressure;
      });
    }, onError: (_) {}, cancelOnError: true);
  }

  Future<void> _requestPermission() async {
    final status = await requestSensorPermission(SensorKind.barometer);
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
    _pressureSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = _availability.isAvailable;
    final needsPermission = _availability.needsPermission;
    final webStatic = kIsWeb && !isAvailable && !needsPermission;

    final content = SensorDisplayCard(
      title: animUi(
        context,
        ja: '現在の大気圧',
        en: 'Current atmospheric pressure',
      ),
      height: widget.height,
      children: isAvailable
          ? (_pressure == null
              ? [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    animUi(
                      context,
                      ja: '気圧データを取得中...',
                      en: 'Reading pressure…',
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ]
              : [
                  Text(
                    "${_pressure!.toStringAsFixed(2)} hPa",
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ])
          : webStatic
              ? const [
                  Text(
                    "0.00 hPa",
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
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
        title: Text(localizeCatalogName(context, '気圧センサー')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: content,
    );
  }
}
