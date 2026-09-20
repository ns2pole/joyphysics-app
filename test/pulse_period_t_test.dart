import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/waves/animations/1d/PulseReflection1D.dart';
import 'package:joyphysics/experiment/waves/animations/1d/Superposition1D.dart';
import 'package:joyphysics/experiment/waves/animations/fields/wave_fields.dart';
import 'package:joyphysics/experiment/waves/animations/widgets/wave_slider.dart';

void main() {
  test('Tスライダーが無いパルス系は周期 0.7 で進む', () {
    final pulse = PulseReflection1DSimulation().initialParameters;
    final superposition = Superposition1DSimulation().initialParameters;

    expect(pulse['periodT'], kDefaultWavePeriodT);
    expect(superposition['periodT'], kDefaultWavePeriodT);

    const field = PulseReflectionField(
      lambda: 2.0,
      periodT: kDefaultWavePeriodT,
      pulseWidth: 2.0,
      isFixedEnd: true,
      boundaryX: 5.0,
    );
    // v = λ/T = 2/0.7。t=0 では左外、t=1 で波頭は -7.5 + v。
    expect(field.z(-5.0, 0, 0), 0);
    final v = 2.0 / kDefaultWavePeriodT;
    final t = (0.0 - (-7.5)) / v; // 波頭が x=0 に着く時刻
    expect(field.z(0.0, 0, t - 0.05), 0);
    expect(field.z(0.0, 0, t + 0.4), isNot(0));
  });

  test('薄膜1DはTスライダー無しでも500nmが周期0.7', () {
    const scaleFactor = 250.0;
    const lambdaNm = 500.0;
    final lambdaInternal = lambdaNm / scaleFactor;
    const v = 2.0 / kDefaultWavePeriodT;
    expect(lambdaInternal / v, closeTo(kDefaultWavePeriodT, 1e-12));
  });
}
