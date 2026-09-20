import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'sensor_availability_types.dart';

const _sensorCheckChannel = MethodChannel('com.joyphysics/sensor_check');

String _sensorType(SensorKind kind) {
  switch (kind) {
    case SensorKind.accelerometer:
      return 'accelerometer';
    case SensorKind.gyroscope:
      return 'gyroscope';
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
    if (available == true) {
      return const SensorAvailability(SensorAvailabilityState.available);
    }
    // Native may return false for an unknown type (e.g. app not fully rebuilt).
    // sensors_plus already supports the gyroscope, so probe the real stream.
    if (kind == SensorKind.gyroscope && await _probeGyroscope()) {
      return const SensorAvailability(SensorAvailabilityState.available);
    }
    return SensorAvailability.unavailable;
  } catch (_) {
    return SensorAvailability.unavailable;
  }
}

Future<bool> _probeGyroscope() async {
  StreamSubscription<GyroscopeEvent>? subscription;
  try {
    final completer = Completer<bool>();
    subscription = gyroscopeEventStream().listen(
      (_) {
        if (!completer.isCompleted) completer.complete(true);
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete(false);
      },
      cancelOnError: true,
    );
    return await completer.future.timeout(
      const Duration(milliseconds: 400),
      onTimeout: () => false,
    );
  } catch (_) {
    return false;
  } finally {
    await subscription?.cancel();
  }
}

Future<SensorAvailability> requestSensorPermission(SensorKind kind) async {
  // Native sensor access in this app does not require explicit permission request flow.
  return checkSensorAvailability(kind);
}
