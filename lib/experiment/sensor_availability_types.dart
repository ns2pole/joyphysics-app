enum SensorKind {
  accelerometer,
  barometer,
  magnetometer,
  microphone,
  light,
}

enum SensorAvailabilityState {
  available,
  unavailable,
  permissionRequired,
  denied,
  checking,
}

class SensorAvailability {
  final SensorAvailabilityState state;
  final String message;

  const SensorAvailability(this.state, {this.message = ''});

  bool get isAvailable => state == SensorAvailabilityState.available;
  bool get needsPermission => state == SensorAvailabilityState.permissionRequired;

  static const checking = SensorAvailability(
    SensorAvailabilityState.checking,
    message: '確認中',
  );

  static const unavailable = SensorAvailability(
    SensorAvailabilityState.unavailable,
    message: '端末非対応',
  );

  static const denied = SensorAvailability(
    SensorAvailabilityState.denied,
    message: '許可が拒否されました',
  );

  static const permissionRequired = SensorAvailability(
    SensorAvailabilityState.permissionRequired,
    message: '利用には許可が必要です',
  );
}
