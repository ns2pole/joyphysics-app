import 'package:flutter/material.dart';
import 'package:joyphysics/model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:joyphysics/dataExporter.dart';
import 'package:joyphysics/experiment/ExperimentView.dart';
import 'package:joyphysics/experiment/dynamics/AccelerometerExperimentWidget.dart';
import 'package:joyphysics/experiment/dynamics/BarometerExperimentWidget.dart';
import 'package:joyphysics/experiment/electroMagnetism/MagnetometerExperimentWidget.dart';
import 'package:joyphysics/experiment/waves/LuxMeasurementWidget.dart';
import 'package:joyphysics/experiment/waves/FrequencyMeasureWidget.dart';
import 'package:joyphysics/experiment/sensor_availability.dart';
import 'package:joyphysics/experiment/sensor_availability_types.dart';
import 'package:joyphysics/shared_components.dart';

class SensorListView extends StatefulWidget {
  const SensorListView({super.key});

  @override
  State<SensorListView> createState() => _SensorListViewState();
}

class _SensorListViewState extends State<SensorListView> {
  final Map<String, SensorAvailability> _availability = {
    '加速度センサー': SensorAvailability.checking,
    '気圧センサー': SensorAvailability.checking,
    '磁気センサー': SensorAvailability.checking,
    '周波数センサー': SensorAvailability.checking,
    '光センサー': SensorAvailability.checking,
  };

  final Map<String, SensorKind> _sensorKinds = const {
    '加速度センサー': SensorKind.accelerometer,
    '気圧センサー': SensorKind.barometer,
    '磁気センサー': SensorKind.magnetometer,
    '周波数センサー': SensorKind.microphone,
    '光センサー': SensorKind.light,
  };

  @override
  void initState() {
    super.initState();
    _checkAllSensors();
  }

  Future<void> _checkAllSensors() async {
    for (final entry in _sensorKinds.entries) {
      final status = await checkSensorAvailability(entry.value);
      if (!mounted) return;
      setState(() {
        _availability[entry.key] = status;
      });
    }
  }

  Future<void> _onTapSensor(
    BuildContext context,
    String key,
    Widget target,
  ) async {
    final kind = _sensorKinds[key];
    final status = _availability[key] ?? SensorAvailability.unavailable;
    if (status.isAvailable) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => target),
      );
      return;
    }
    if (kind != null && status.needsPermission) {
      final granted = await requestSensorPermission(kind);
      if (!mounted) return;
      setState(() {
        _availability[key] = granted;
      });
      if (granted.isAvailable) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => target),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(granted.message)),
        );
      }
    }
  }

  final List<Map<String, dynamic>> sensors = [
    {
      'name': '加速度センサー',
      'icon': Icons.speed,
      'widget': AccelerometerExperimentWidget(),
      'key': '加速度センサー',
    },
    {
      'name': '気圧センサー',
      'icon': Icons.compress,
      'widget': BarometerExperimentWidget(),
      'key': '気圧センサー',
    },
    {
      'name': '磁気センサー',
      'icon': Icons.sensors,
      'widget': MagnetometerExperimentWidget(height: 380),
      'key': '磁気センサー',
    },
    {
      'name': '周波数センサー(音波)',
      'icon': Icons.graphic_eq,
      'widget': FrequencyMeasureWidget(),
      'key': '周波数センサー',
    },
    if (!(kIsWeb || defaultTargetPlatform == TargetPlatform.iOS))
      {
        'name': '光センサー',
        'icon': Icons.wb_sunny,
        'widget': LuxMeasurementWidget(),
        'key': '光センサー',
      },
  ];

  final Map<String, List<Video>> articlesByCategory = {
    '加速度センサー': [accelerometer],
    '気圧センサー': [barometer],
    '磁気センサー': [magnetometer],
    '周波数センサー': [frequencyAndDoReMi, beat, doppler, dopplerObserverMoving],
    '光センサー': [luxMeasurement],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('センサーを使う')),
      body: ListView.separated(
        itemCount: sensors.length + 1, // +1 = 解説記事リンク
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) {
          if (index < sensors.length) {
            final sensor = sensors[index];
            final availabilityKey = sensor['key'] as String;
            final status =
                _availability[availabilityKey] ?? SensorAvailability.unavailable;
            final isAvailable = status.isAvailable;
            final canTap = isAvailable || status.needsPermission;
            final String titleSuffix;
            if (isAvailable) {
              titleSuffix = '';
            } else if (status.needsPermission) {
              titleSuffix = '(許可が必要)';
            } else if (status.state == SensorAvailabilityState.denied) {
              titleSuffix = '(許可拒否)';
            } else if (status.state == SensorAvailabilityState.checking) {
              titleSuffix = '(確認中)';
            } else {
              titleSuffix = '(端末非対応)';
            }

            return ListTile(
              leading: Icon(
                sensor['icon'],
                color: isAvailable ? null : Colors.grey,
              ),
              title: Text(
                '${sensor['name']}$titleSuffix',
                style: TextStyle(
                  color: isAvailable ? null : Colors.grey,
                ),
              ),
              enabled: canTap,
              onTap: canTap
                  ? () => _onTapSensor(
                        context,
                        availabilityKey,
                        sensor['widget'] as Widget,
                      )
                  : null,
            );
          } else {
            // 一番下の「解説記事一覧」
            return _buildArticlesAccordion(context);
          }
        },
      ),
    );
  }

  Widget _buildArticlesAccordion(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.menu_book, color: Colors.blue),
      title: Text(
        'センサー実験\ 解説記事一覧',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: true,
      children: articlesByCategory.entries.map((entry) {
        final categoryName = entry.key;
        final videos = entry.value;
        return _buildCategory(context, categoryName, videos);
      }).toList(),
    );
  }

  Widget _buildCategory(
      BuildContext context, String categoryName, List<Video> videos) {
    final bool isAvailable =
        (_availability[categoryName] ?? SensorAvailability.unavailable).isAvailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(name: categoryName, disabled: !isAvailable, fontSize: 16),
        ...videos.map((video) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 2),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              leading: Opacity(
                opacity: isAvailable ? 1.0 : 0.5,
                child: Image.asset(
                  'assets/icon/smartphone_only.png',
                  width: 60,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              title: Text(
                video.title,
                style: TextStyle(
                  fontSize: 15,
                  color: isAvailable ? Colors.black87 : Colors.grey,
                ),
              ),
              tileColor: isAvailable
                  ? Colors.blue[50]?.withOpacity(0.1)
                  : Colors.grey[100]?.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              enabled: isAvailable,
              onTap: isAvailable
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => VideoDetailView(video: video)),
                      );
                    }
                  : null,
            ),
          );
        }).toList(),
        SizedBox(height: 4),
      ],
    );
  }
}
