import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/elevatorInertial1D.dart';

void main() {
  const params = ElevatorInertialParams(accel: 3, mass: 1);

  test('上昇では張力は m(g+A)、物体は上向きに加速する', () {
    expect(elevatorTension(ElevatorMotionKind.up, params), closeTo(1 * (9.8 + 3), 1e-12));
    final mid = elevatorInertialAt(ElevatorMotionKind.up, params, 0.8);
    expect(mid.a, closeTo(3, 1e-12));
    expect(mid.v, closeTo(2.4, 1e-12));
    expect(mid.y, closeTo(0.5 * 3 * 0.64, 1e-12));
    expect(mid.tension, closeTo(12.8, 1e-12));
  });

  test('下降では張力は m(g-A) で、加速度は下向き', () {
    expect(elevatorTension(ElevatorMotionKind.down, params), closeTo(1 * (9.8 - 3), 1e-12));
    final mid = elevatorInertialAt(ElevatorMotionKind.down, params, 0.8);
    expect(mid.a, closeTo(-3, 1e-12));
    expect(mid.v, lessThan(0));
    expect(mid.y, closeTo(-0.5 * 3 * 0.64, 1e-12));
    expect(mid.tension, greaterThan(0));
  });

  test('A = 0 では上昇も下降も張力は mg', () {
    const still = ElevatorInertialParams(accel: 0, mass: 2);
    expect(elevatorTension(ElevatorMotionKind.up, still), closeTo(19.6, 1e-12));
    expect(elevatorTension(ElevatorMotionKind.down, still), closeTo(19.6, 1e-12));
  });

  test('質量を変えても a は変わらず、張力は質量に比例する', () {
    const heavy = ElevatorInertialParams(accel: 3, mass: 2);
    final light = elevatorInertialAt(ElevatorMotionKind.up, params, 1);
    final twice = elevatorInertialAt(ElevatorMotionKind.up, heavy, 1);
    expect(twice.a, closeTo(light.a, 1e-12));
    expect(twice.y, closeTo(light.y, 1e-12));
    expect(twice.tension, closeTo(light.tension * 2, 1e-12));
  });

  test('力学の慣性力にエレベータがある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final sections = dynamics.subcategories.where((s) => s.name == '慣性力');
    expect(sections.length, 1);
    expect(sections.single.videos, contains(elevatorInertial1D));
  });
}
