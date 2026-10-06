import 'package:flutter/material.dart';
import 'package:joyphysics/model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:joyphysics/experiment/ExperimentView.dart';
import 'package:joyphysics/experiment/dynamics/AccelerometerExperimentWidget.dart';
import 'package:joyphysics/experiment/dynamics/GyroscopeExperimentWidget.dart';
import 'package:joyphysics/experiment/dynamics/BarometerExperimentWidget.dart';
import 'package:joyphysics/experiment/electroMagnetism/MagnetometerExperimentWidget.dart';
import 'package:joyphysics/experiment/waves/LuxMeasurementWidget.dart';
import 'package:joyphysics/experiment/waves/FrequencyMeasureWidget.dart';
import 'package:joyphysics/experiment/sensorArticlesData.dart';
import 'package:joyphysics/experiment/sensor_availability.dart';
import 'package:joyphysics/experiment/sensor_availability_types.dart';
import 'package:joyphysics/experiment/sensor_gadget_l10n.dart';
import 'package:joyphysics/l10n/app_localizations.dart';
import 'package:joyphysics/l10n/catalog_name_localizations.dart';
import 'package:joyphysics/shared_components.dart';
import 'package:joyphysics/utils/locale_utils.dart';

class SensorListView extends StatefulWidget {
  const SensorListView({super.key});

  @override
  State<SensorListView> createState() => _SensorListViewState();
}

class _SensorListViewState extends State<SensorListView> {
  final Map<String, SensorAvailability> _availability = {
    '加速度センサー': SensorAvailability.checking,
    'ジャイロセンサー': SensorAvailability.checking,
    '気圧センサー': SensorAvailability.checking,
    '磁気センサー': SensorAvailability.checking,
    '周波数センサー': SensorAvailability.checking,
    '光センサー': SensorAvailability.checking,
  };

  final Map<String, SensorKind> _sensorKinds = const {
    '加速度センサー': SensorKind.accelerometer,
    'ジャイロセンサー': SensorKind.gyroscope,
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
          SnackBar(
            content: Text(sensorAvailabilityMessage(context, granted)),
          ),
        );
      }
      return;
    }
    if (kIsWeb) {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => target),
      );
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
      'name': 'ジャイロセンサー',
      'icon': Icons.rotate_right,
      'widget': GyroscopeExperimentWidget(),
      'key': 'ジャイロセンサー',
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
    if (defaultTargetPlatform != TargetPlatform.iOS)
      {
        'name': '光センサー',
        'icon': Icons.wb_sunny,
        'widget': LuxMeasurementWidget(),
        'key': '光センサー',
      },
  ];

  String _titleSuffix(AppLocalizations l10n, SensorAvailability status) {
    if (status.isAvailable) return '';
    if (status.needsPermission) return l10n.sensorPermissionRequiredSuffix;
    if (status.state == SensorAvailabilityState.denied) {
      return l10n.sensorPermissionDeniedSuffix;
    }
    if (status.state == SensorAvailabilityState.checking) {
      return l10n.sensorCheckingSuffix;
    }
    return l10n.sensorUnsupportedSuffix;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.useSensorsTitle)),
      body: ListView.separated(
        itemCount: sensors.length + 1, // +1 = 解説記事
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          if (index < sensors.length) {
            final sensor = sensors[index];
            final availabilityKey = sensor['key'] as String;
            final nameKey = sensor['name'] as String;
            final status =
                _availability[availabilityKey] ?? SensorAvailability.unavailable;
            final isAvailable = status.isAvailable;
            final isChecking = status.state == SensorAvailabilityState.checking;
            final canTap = isAvailable ||
                status.needsPermission ||
                (kIsWeb && !isChecking);
            final titleSuffix = _titleSuffix(l10n, status);
            final displayName = localizeCatalogName(context, nameKey);

            return ListTile(
              leading: Icon(
                sensor['icon'],
                color: (isAvailable || kIsWeb) ? null : Colors.grey,
              ),
              title: Text(
                '$displayName$titleSuffix',
                style: TextStyle(
                  color: (isAvailable || kIsWeb) ? null : Colors.grey,
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
            return _buildArticlesAccordion(context);
          }
        },
      ),
    );
  }

  Widget _buildArticlesAccordion(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      leading: const Icon(Icons.menu_book, color: Colors.blue),
      title: Text(
        l10n.sensorArticlesSection,
        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: true,
      children: sensorArticlesByCategory.entries.map((entry) {
        final categoryName = entry.key;
        final videos = entry.value;
        return _buildCategory(context, categoryName, videos);
      }).toList(),
    );
  }

  Widget _buildCategory(
      BuildContext context, String categoryName, List<Video> videos) {
    final bool hasLinkedSensor = _sensorKinds.containsKey(categoryName);
    final bool isAvailable =
        (_availability[categoryName] ?? SensorAvailability.unavailable)
            .isAvailable;
    final bool articleUsable = !hasLinkedSensor || isAvailable || kIsWeb;
    final lang = appLanguageCode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          name: localizeCatalogName(context, categoryName),
          disabled: !articleUsable,
          fontSize: 16,
        ),
        ...videos
            .where((video) => video.isAvailableForLanguage(lang))
            .map((video) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32 / 3, vertical: 2),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              leading: Opacity(
                opacity: articleUsable ? 1.0 : 0.5,
                child: Image.asset(
                  isEnglishAppLocale(context)
                      ? 'assets/icon/smartphone_only_en.png'
                      : 'assets/icon/smartphone_only.png',
                  width: 60,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              title: Text(
                video.localizedTitle(lang),
                style: TextStyle(
                  fontSize: 15,
                  color: articleUsable ? Colors.black87 : Colors.grey,
                ),
              ),
              tileColor: articleUsable
                  ? Colors.blue[50]?.withOpacity(0.1)
                  : Colors.grey[100]?.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              enabled: articleUsable,
              onTap: articleUsable
                  ? () {
                      openVideoDetail(context, video);
                    }
                  : null,
            ),
          );
        }),
        const SizedBox(height: 4),
      ],
    );
  }
}
