import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/waves/animations/1d/CoupledOscillatorLongitudinal1D.dart';
import 'package:joyphysics/experiment/waves/animations/1d/coupled_oscillator_transverse_physics.dart';

Future<void> _pumpLongitudinalSim(
  WidgetTester tester,
  CoupledOscillatorLongitudinal1DSimulation sim, {
  double height = 920,
}) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PhysicsSimulationView(
            simulation: sim,
            height: height,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  test('初期は左の質点だけ右に変位している', () {
    final params = CoupledOscillatorLongitudinal1DSimulation().initialParameters;
    expect(params['n'], kCoupledOscillatorLongitudinalDefaultN);
    expect(params['mode'], 0);
    expect(params['u1']!, greaterThan(0.5));
    expect(params['u2'], 0);
    expect(params['u50'], 0);
    expect(params.containsKey('u51'), isFalse);
  });

  test('N は 2 から 50、左右パディングは 0', () {
    expect(kCoupledOscillatorMinN, 2);
    expect(kCoupledOscillatorLongitudinalMaxN, 50);
    expect(kCoupledOscillatorLongitudinalDefaultN, 30);
    expect(kCoupledOscillatorLongitudinalPadX, 0);
    const size = Size(400, 200);
    final layout = LongitudinalChainLayout(size, 30);
    expect(layout.wallLeft().dx, 0);
    expect(layout.wallRight().dx, 400);
    expect(layout.ampPx, closeTo(layout.spacing * 0.52, 1e-9));
  });

  test('横波表示の質点xは縦波の平衡位置と同じ', () {
    const size = Size(400, 200);
    const n = 30;
    const padX = 8.0;
    final layout = LongitudinalChainLayout(size, n);
    final massXs = transverseDisplacementGraphMassXs(size, n);
    expect(massXs.length, n);
    for (int i = 0; i < n; i++) {
      final tx = padX + (size.width - 2 * padX) * (i + 1) / (n + 1);
      expect(layout.xEq(i), closeTo(tx, 1e-9));
      expect(massXs[i], closeTo(layout.xEq(i), 1e-9));
    }
  });

  test('横波の平衡位置刻みは質点の元の x に並ぶ', () {
    const size = Size(400, 200);
    const n = 5;
    final massXs = transverseDisplacementGraphMassXs(size, n);
    expect(massXs, hasLength(n));
    expect(massXs.first, greaterThan(kTransverseDisplacementGraphPadX));
    expect(
      massXs.last,
      lessThan(size.width - kTransverseDisplacementGraphPadX),
    );
    for (int i = 1; i < n; i++) {
      expect(massXs[i] - massXs[i - 1], closeTo(massXs[1] - massXs[0], 1e-9));
    }
  });

  test('N=50 でも1質点変位の初期形が t=0 で戻る', () {
    final y0 = List<double>.filled(kCoupledOscillatorLongitudinalMaxN, 0.0);
    y0[0] = kCoupledOscillatorLongitudinalAmplitude;
    final v0 = List<double>.filled(kCoupledOscillatorLongitudinalMaxN, 0.0);
    final modes = projectCoupledOscillator(y0: y0, v0: v0);
    final snap = evolveCoupledOscillator(modes, 0);
    expect(snap.y[0], closeTo(kCoupledOscillatorLongitudinalAmplitude, 1e-10));
    for (int i = 1; i < kCoupledOscillatorLongitudinalMaxN; i++) {
      expect(snap.y[i], closeTo(0, 1e-10));
    }
  });

  testWidgets('デフォルトで再生・リセットのアイコンが出る', (tester) async {
    await _pumpLongitudinalSim(
      tester,
      CoupledOscillatorLongitudinal1DSimulation(),
    );

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.restore), findsOneWidget);
    expect(find.text('n=1'), findsNothing);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
  });

  testWidgets('再生後に一時停止しても時刻がゼロに戻らない', (tester) async {
    final sim = CoupledOscillatorLongitudinal1DSimulation();
    await _pumpLongitudinalSim(tester, sim);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    sim.simTime.value = 1.75;
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();

    expect(sim.running.value, isFalse);
    expect(sim.simTime.value, closeTo(1.75, 0.05));
    expect(sim.simTime.value, greaterThan(1.0));
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.textContaining('一時停止'), findsOneWidget);
  });

  testWidgets('一時停止してリセットしたあと N を変えられる', (tester) async {
    final sim = CoupledOscillatorLongitudinal1DSimulation();
    await _pumpLongitudinalSim(tester, sim);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.restore));
    await tester.pump();

    final addButton = find.byIcon(Icons.add);
    await tester.ensureVisible(addButton);
    await tester.pump();
    await tester.tap(addButton);
    await tester.pump();

    expect(
      find.text('${kCoupledOscillatorLongitudinalDefaultN + 1}'),
      findsWidgets,
    );
  });

  testWidgets('N の + を押すと質点が増える', (tester) async {
    await _pumpLongitudinalSim(
      tester,
      CoupledOscillatorLongitudinal1DSimulation(),
    );

    final addButton = find.byIcon(Icons.add);
    await tester.ensureVisible(addButton);
    await tester.pump();
    await tester.tap(addButton);
    await tester.pump();

    expect(find.text('${kCoupledOscillatorLongitudinalDefaultN + 1}'), findsWidgets);
  });

  test('隣接点の相対変位から疎・密・なしを判定する', () {
    expect(longitudinalDensityLabel(0.2), '疎');
    expect(longitudinalDensityLabel(-0.2), '密');
    expect(longitudinalDensityLabel(0.01), isNull);

    // 質点1だけ右へ: 左壁〜1は伸び(疎)、1〜2は縮み(密)
    final labels = longitudinalDensityLabels([0.75, 0.0, 0.0]);
    expect(labels.length, 4);
    expect(labels[0], '疎'); // 0 → 0.75
    expect(labels[1], '密'); // 0.75 → 0
    expect(labels[2], isNull);
    expect(labels[3], isNull);
  });

  test('わずかな疎密は出さず、ピークだけ残す', () {
    final weak = longitudinalDensityLabels(
      [0.04, 0.03, 0.02, 0.01],
      peaksOnly: true,
    );
    expect(weak.every((e) => e == null), isTrue);

    final mixed = longitudinalDensityLabels(
      [0.75, 0.08, 0.04, 0.0],
      peaksOnly: true,
    );
    expect(mixed.where((e) => e != null).length, lessThanOrEqualTo(2));
    expect(mixed.contains('疎'), isTrue);
    expect(mixed.contains('密'), isTrue);
    expect(mixed[2], isNull);
    expect(mixed[3], isNull);
  });

  test('peaksOnly なしなら閾値を超えた区間すべてに疎密が付く', () {
    final all = longitudinalDensityLabels(
      [0.75, 0.0, 0.0],
      peaksOnly: false,
    );
    expect(all[0], '疎');
    expect(all[1], '密');
    expect(all[2], isNull);
    expect(all[3], isNull);
  });

  test('疎密マークの縦点線は区間（平衡位置）の中点から下ろす', () {
    const eqXs = [0.0, 40.0, 80.0, 120.0, 160.0];
    expect(longitudinalDensityGuideX(0, eqXs), 20.0);
    expect(longitudinalDensityGuideX(1, eqXs), 60.0);
    expect(longitudinalDensityGuideX(2, eqXs), 100.0);
    expect(longitudinalDensityGuideX(3, eqXs), 140.0);
  });

  test('疎密マークは点線の真下（区間の中点）に置く', () {
    const eqXs = [0.0, 40.0, 80.0, 120.0, 160.0];
    final marks = layoutLongitudinalDensityMarks(
      labels: ['疎', '密', null, null],
      equilibriumXs: eqXs,
      radius: 10,
      baseY: 80,
      maxY: 140,
    );
    expect(marks.map((m) => m.x).toSet(), {20.0, 60.0});
    expect(marks.any((m) => m.x == 40 || m.x == 80), isFalse);
  });

  test('近い疎密マークは点線を伸ばして下へ避ける', () {
    const eqXs = [0.0, 8.0, 16.0, 80.0, 90.0];
    final marks = layoutLongitudinalDensityMarks(
      labels: ['疎', '密', null, null],
      equilibriumXs: eqXs,
      radius: 10,
      baseY: 80,
      maxY: 140,
    );
    expect(marks.length, greaterThanOrEqualTo(2));
    final ys = marks.map((m) => m.y).toSet();
    expect(ys.length, greaterThan(1));
    expect(marks.map((m) => m.y).reduce(math.max), greaterThan(80));
  });

  test('横波表示の縦点線は振幅があっても下余白に届く', () {
    const size = Size(400, 240);
    final mid = transverseDisplacementGraphMidY(size);
    final amp = transverseDisplacementGraphAmpPx(size);
    final scaled = math.min(
      0.75 * kTransverseDisplacementGraphExaggerate,
      kTransverseDisplacementGraphExaggerateClamp,
    );
    final troughY = mid + scaled * amp;
    const labelY = 240.0 - 22.0;
    expect(kTransverseDisplacementGraphFlex, 2 * 4);
    expect(kTransverseDisplacementGraphExaggerate, 4.0);
    // 強調後は谷がラベル帯に食い込むことがあるが、キャンバス内に収める
    expect(troughY, lessThan(size.height - 2));
    expect(labelY, lessThan(size.height));
  });

  test('横波表示の下余白は pause 前後で同じ', () {
    expect(kTransverseDisplacementGraphBottom, greaterThanOrEqualTo(54));
    expect(kTransverseDisplacementGraphFlex, 8);
    expect(kTransverseDisplacementGraphFlex, greaterThan(kLongitudinalChainFlex));
    const size = Size(400, 160);
    final amp = transverseDisplacementGraphAmpPx(size);
    final mid = transverseDisplacementGraphMidY(size);
    expect(
      amp,
      closeTo(
        (160 - kTransverseDisplacementGraphTop - kTransverseDisplacementGraphBottom) *
            kTransverseDisplacementGraphAmpFrac,
        1e-9,
      ),
    );
    expect(
      mid,
      closeTo(
        kTransverseDisplacementGraphTop +
            (160 - kTransverseDisplacementGraphTop - kTransverseDisplacementGraphBottom) *
                kTransverseDisplacementGraphMidFrac,
        1e-9,
      ),
    );
  });
}
