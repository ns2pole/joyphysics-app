# JoyPhysics animation UI i18n checklist

Generated: 2026-10-06
Progress: **71/71** simulation articles

Done when the article file's interactive labels go through `animL` / `animUi`.
`animL` uses only the primary device locale: English stays English when Japanese
is installed as a secondary locale. Article `Video` / `createWaveVideo` HTML is out of scope.

Shared widgets are not their own articles. Every `animL` pair under `animations/`,
including these, is checked by `test/l10n/animation_animl_pairs_test.dart`:

- `lib/experiment/waves/animations/fields/wave_fields.dart`
- `lib/experiment/thermoDynamics/animations/common.dart`
- `lib/experiment/dynamics/animations/energy_gauge.dart`

| Done | ID | Title | File | UI |
|---|---|---|---|---|
| [x] | `kineticFriction1D` | 水平面上の動摩擦力 | `lib/experiment/dynamics/animations/kineticFriction1D.dart` | animL |
| [x] | `kineticFrictionIncline1D` | 斜面上の動摩擦力 | `lib/experiment/dynamics/animations/kineticFrictionIncline1D.dart` | animL |
| [x] | `horizontalSpring1D` | 水平バネ | `lib/experiment/dynamics/animations/springOscillator1D.dart` | animL |
| [x] | `roughHorizontalSpring1D` | 水平バネ(粗い床) | `lib/experiment/dynamics/animations/roughHorizontalSpring1D.dart` | animL |
| [x] | `verticalSpring1D` | 鉛直バネ | `lib/experiment/dynamics/animations/springOscillator1D.dart` | animL |
| [x] | `floatingOscillation1D` | 浮力による単振動 | `lib/experiment/dynamics/animations/floatingOscillation1D.dart` | animL |
| [x] | `platformSpring1D` | ばね上の台とおもり | `lib/experiment/dynamics/animations/platformSpring1D.dart` | animL |
| [x] | `freeFall1D` | 自由落下 | `lib/experiment/dynamics/animations/verticalMotion1D.dart` | animL |
| [x] | `verticalThrow1D` | 鉛直投げ上げ・投げ下げ | `lib/experiment/dynamics/animations/verticalMotion1D.dart` | animL |
| [x] | `linearDrag1D` | 速度比例の空気抵抗 | `lib/experiment/dynamics/animations/linearDrag1D.dart` | animL |
| [x] | `projectileMotion2D` | 斜方投射 | `lib/experiment/dynamics/animations/projectileMotion2D.dart` | animL |
| [x] | `atwoodMachine1D` | 定滑車(アトウッドの器械) | `lib/experiment/dynamics/animations/atwoodMachine1D.dart` | animL |
| [x] | `movablePulley1D` | 動滑車 | `lib/experiment/dynamics/animations/movablePulley1D.dart` | animL |
| [x] | `movableWedge1D` | 動く斜面と慣性力 | `lib/experiment/dynamics/animations/movableWedge1D.dart` | animL |
| [x] | `elevatorInertial1D` | エレベータの上昇・下降 | `lib/experiment/dynamics/animations/elevatorInertial1D.dart` | animL |
| [x] | `trainPendulumInertial2D` | 加速する電車の振り子 | `lib/experiment/dynamics/animations/trainPendulumInertial2D.dart` | animL |
| [x] | `centrifugalForce2D` | 遠心力 | `lib/experiment/dynamics/animations/centrifugalForce2D.dart` | animL |
| [x] | `coriolisSpiral2D` | 遠心力とコリオリ力(等速直線運動) | `lib/experiment/dynamics/animations/coriolisSpiral2D.dart` | animL |
| [x] | `eulerForce2D` | オイラー力 | `lib/experiment/dynamics/animations/eulerForce2D.dart` | animL |
| [x] | `beadOnRotatingRing3D` | 回転する円環上のビーズ | `lib/experiment/dynamics/animations/beadOnRotatingRing3D.dart` | animL |
| [x] | `earthStandingPerson3D` | 地上に立つ人と遠心力 | `lib/experiment/dynamics/animations/earthStandingPerson3D.dart` | animL |
| [x] | `simplePendulum2D` | 単振り子の近似と厳密 | `lib/experiment/dynamics/animations/simplePendulum2D.dart` | animL |
| [x] | `conicalPendulum3D` | 円錐振り子 | `lib/experiment/dynamics/animations/conicalPendulum3D.dart` | animL |
| [x] | `collision1D` | 1次元の衝突 | `lib/experiment/dynamics/animations/collision1D.dart` | animL |
| [x] | `bounce1D` | 跳ね返り1次元 | `lib/experiment/dynamics/animations/bounce.dart` | animL |
| [x] | `bounce2D` | 跳ね返り2次元 | `lib/experiment/dynamics/animations/bounce.dart` | animL |
| [x] | `uniformCircularMotion2D` | 等速円運動 | `lib/experiment/dynamics/animations/uniformCircularMotion2D.dart` | animL |
| [x] | `verticalLoop2D` | ジェットコースター | `lib/experiment/dynamics/animations/verticalLoop2D.dart` | animL |
| [x] | `keplerLaws2D` | ケプラーの3法則 | `lib/experiment/dynamics/animations/keplerLaws2D.dart` | animL |
| [x] | `twoBodySpring1D` | 2体問題(ばね・1次元) | `lib/experiment/dynamics/animations/twoBodySpring1D.dart` | animL |
| [x] | `twoBodyKepler2D` | 2体問題(重力・連星) | `lib/experiment/dynamics/animations/twoBodyKepler2D.dart` | animL |
| [x] | `leaningRodStatics2D` | 立て掛けた棒（壁滑らか） | `lib/experiment/dynamics/animations/leaningRodStatics2D.dart` | animL |
| [x] | `pushedBlock2D` | 直方体を押す（滑りと転倒） | `lib/experiment/dynamics/animations/pushedBlock2D.dart` | animL |
| [x] | `coupledOscillatorLongitudinal1D` | 縦波,疎密波(N体バネ) | `lib/experiment/waves/animations/1d/CoupledOscillatorLongitudinal1D.dart` | animL |
| [x] | `coupledOscillatorTransverse1D` | 横波(N体バネ) | `lib/experiment/waves/animations/1d/CoupledOscillatorTransverse1D.dart` | animL |
| [x] | `waveEquation1D` | 波の式 | `lib/experiment/waves/animations/1d/WaveEquation1D.dart` | animL |
| [x] | `superposition1D` | 重ね合わせの原理 | `lib/experiment/waves/animations/1d/Superposition1D.dart` | animL |
| [x] | `beating1D` | うなり | `lib/experiment/waves/animations/1d/Beating1D.dart` | animL |
| [x] | `planeWave` | 直線波 | `lib/experiment/waves/animations/2d/PlaneWave.dart` | animL |
| [x] | `circularWave` | 円形波 | `lib/experiment/waves/animations/2d/CircularWave.dart` | animL |
| [x] | `twoSource1D` | 1次元干渉 | `lib/experiment/waves/animations/1d/TwoSource1D.dart` | animL |
| [x] | `planeWaveInterference` | 直線波干渉 | `lib/experiment/waves/animations/2d/PlaneWaveInterference.dart` | animL |
| [x] | `circularPlaneInterference` | 円形波と直線波の干渉 | `lib/experiment/waves/animations/2d/CircularPlaneInterference.dart` | animL |
| [x] | `circularInterference` | 円形波干渉 | `lib/experiment/waves/animations/2d/CircularInterference.dart` | animL |
| [x] | `thinFilmInterference1D` | 薄膜干渉 (1次元) | `lib/experiment/waves/animations/1d/ThinFilmInterference1D.dart` | animL |
| [x] | `thinFilmInterference2D` | 薄膜干渉 (2次元) | `lib/experiment/waves/animations/2d/ThinFilmInterference2D.dart` | animL |
| [x] | `refraction1D` | 1次元屈折 | `lib/experiment/waves/animations/1d/Refraction1D.dart` | animL |
| [x] | `refractionLaw` | 2次元直線波の屈折 | `lib/experiment/waves/animations/2d/RefractionLaw.dart` | animL |
| [x] | `pulseReflection1D` | 1次元パルスの反射 | `lib/experiment/waves/animations/1d/PulseReflection1D.dart` | animL |
| [x] | `fixedEndReflection1D` | 1次元の定在波(固定端反射) | `lib/experiment/waves/animations/1d/FixedEndReflection1D.dart` | animL |
| [x] | `freeEndReflection1D` | 1次元の定在波(自由端反射) | `lib/experiment/waves/animations/1d/FreeEndReflection1D.dart` | animL |
| [x] | `reflectionLaw2D` | 反射の法則 (自由端・2次元) | `lib/experiment/waves/animations/2d/ReflectionLaw2D.dart` | animL |
| [x] | `fixedReflection2D` | 反射の法則 (固定端・2次元) | `lib/experiment/waves/animations/2d/FixedReflection2D.dart` | animL |
| [x] | `dopplerEffect1D` | 1次元ドップラー効果(音源移動) | `lib/experiment/waves/animations/1d/DopplerEffect1D.dart` | animL |
| [x] | `dopplerEffectObserverMoving1D` | 1次元ドップラー効果(観測者移動) | `lib/experiment/waves/animations/1d/DopplerEffectObserverMoving1D.dart` | animL |
| [x] | `dopplerEffect2D` | 2次元ドップラー効果(音源移動) | `lib/experiment/waves/animations/2d/DopplerEffect2D.dart` | animL |
| [x] | `dopplerEffectObserverMoving` | 2次元ドップラー効果(観測者移動) | `lib/experiment/waves/animations/2d/DopplerEffectObserverMoving.dart` | animL |
| [x] | `movingReflector1D` | 動く物体による反射 | `lib/experiment/waves/animations/1d/MovingReflector1D.dart` | animL |
| [x] | `closedPipeWaterResonance1D` | 気柱の振動(閉管) | `lib/experiment/waves/animations/1d/ClosedPipeWaterResonance1D.dart` | animL |
| [x] | `drivenStringResonance1D` | 弦上の定在波(駆動) | `lib/experiment/waves/animations/1d/DrivenStringResonance1D.dart` | animL |
| [x] | `youngDoubleSlit` | ヤングの実験 | `lib/experiment/waves/animations/2d/YoungDoubleSlit.dart` | animL |
| [x] | `dispersionHalfPlane2D` | 2次元直線波の分散 | `lib/experiment/waves/animations/2d/DispersionHalfPlane2D.dart` | animL |
| [x] | `rainbowDroplet2D` | 単一水滴の光路（主虹） | `lib/experiment/waves/animations/2d/RainbowDroplet2D.dart` | animL |
| [x] | `secondaryRainbowDroplet2D` | 単一水滴の光路（副虹） | `lib/experiment/waves/animations/2d/SecondaryRainbowDroplet2D.dart` | animL |
| [x] | `rainbowMultiDroplet2D` | 主虹（多数水滴） | `lib/experiment/waves/animations/2d/RainbowDroplet2D.dart` | animL |
| [x] | `secondaryRainbowMultiDroplet2D` | 副虹（多数水滴） | `lib/experiment/waves/animations/2d/SecondaryRainbowDroplet2D.dart` | animL |
| [x] | `isochoricProcess` | 定積変化 | `lib/experiment/thermoDynamics/animations/IsochoricProcess.dart` | animL |
| [x] | `isobaricProcess` | 定圧変化 | `lib/experiment/thermoDynamics/animations/IsobaricProcess.dart` | animL |
| [x] | `isothermalProcess` | 等温変化 | `lib/experiment/thermoDynamics/animations/IsothermalProcess.dart` | animL |
| [x] | `adiabaticProcess` | 断熱変化 | `lib/experiment/thermoDynamics/animations/AdiabaticProcess.dart` | animL |
| [x] | `heatCycleProcess` | 熱機関と熱サイクル | `lib/experiment/thermoDynamics/animations/HeatCycle.dart` | animL |
