import 'package:flutter/services.dart';
import 'sensor_availability_types.dart';

const _sensorCheckChannel = MethodChannel('com.joyphysics/sensor_check');

String _sensorType(SensorKind kind) {
  switch (kind) {
    case SensorKind.accelerometer:
      return 'accelerometer';
    case SensorKind.barometer:
      return 'barometer';
    case SensorKind.magnetometer:
      return 'magnetometer';
    case SensorKind.microphone:
      return 'microphone';
    case SensorKind.light:
      return 'light';
  }
}

Future<SensorAvailability> checkSensorAvailability(SensorKind kind) async {
  try {
    final available = await _sensorCheckChannel.invokeMethod<bool>(
      'isSensorAvailable',
      {'sensorType': _sensorType(kind)},
    );
    return (available ?? false)
        ? const SensorAvailability(SensorAvailabilityState.available)
        : SensorAvailability.unavailable;
  } catch (_) {
    return SensorAvailability.unavailable;
  }
}

Future<SensorAvailability> requestSensorPermission(SensorKind kind) async {
  // Native sensor access in this app does not require explicit permission request flow.
  return checkSensorAvailability(kind);
}
