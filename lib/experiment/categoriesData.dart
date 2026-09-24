import 'package:joyphysics/model.dart';
import 'package:joyphysics/dataExporter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final categoriesData = <Category>[
  // 力学
  Category(
    name: '力学',
    gifUrl: 'assets/init/dynamics.gif',
    subcategories: [
      // Subcategory(        
      //   name: '加速度センサー',
      //   videos: [
      //     accelerometer
      //   ],
      // ),
      Subcategory(
        name: '摩擦',
        videos: [
          staticFriction,
          kineticFriction,
          kineticFriction1D,
          kineticFrictionIncline1D,
        ],
      ),
      Subcategory(
        name: '浮力',
        videos: [
          buoyancyAndActionReaction,
          buoyancyComparison,
        ],
      ),
      Subcategory(
        name: '単振動',
        videos: [
          floatingOscillation1D,
        ],
      ),
      Subcategory(
        name: 'バネ',
        videos: [
          fook,
          horizontalSpring1D,
          roughHorizontalSpring1D,
          verticalSpring1D,
          verticalSpringOscillation,
        ],
      ),
      Subcategory(
        name: '落下運動',
        videos: [
          freeFall,
          freeFall1D,
          verticalThrow1D,
          linearDrag1D,
          projectileMotion2D,
        ],
      ),
      Subcategory(
        name: '滑車',
        videos: [
          atwoodMachine1D,
          movablePulley1D,
        ],
      ),
      Subcategory(
        name: '慣性力',
        videos: [
          movableWedge1D,
          elevatorInertial1D,
          trainPendulumInertial2D,
          centrifugalForce2D,
          coriolisCentripetal2D,
          coriolisSpiral2D,
          eulerForce2D,
        ],
      ),
      Subcategory(
        name: '振り子',
        videos: [
          pendulumPeriodMeasurement,
        ],
      ),
      Subcategory(
        name: '衝突',
        videos: [
          collision1D,
          elasticCollision1D,
          elasticCollision2D,
          bounce1D,
          bounce2D,
        ],
      ),
      Subcategory(
        name: '円運動',
        videos: [
          uniformCircularMotion2D,
          verticalLoop2D,
          centripetalForceDisappears
        ],
      ),
      Subcategory(
        name: 'ケプラーの法則',
        videos: [
          keplerLaws2D,
          planets,
          moonOrbit,
          jupiter,
        ],
      ),
      Subcategory(
        name: '2体問題',
        videos: [
          twoBodySpring1D,
          twoBodyKepler2D,
        ],
      ),
      Subcategory(
        name: '剛体',
        videos: [
          oneSideLift,
          buildingBlocksStability,
        ],
      ),
    ],
  ),

  // 電磁気学
  Category(
    name: '電磁気学',
    gifUrl: 'assets/init/electromag.gif',
    subcategories: [
      Subcategory(
        name: 'コンデンサ',
        videos: [
          capacitorIntroduction,
          parallelPlateCapacitanceMeasurement,
          capacitanceSeriesCombination,
          capacitanceParallelCombination,
          capacitorChargeStorage,
        ],
      ),
      Subcategory(
        name: '抵抗',
        videos: [
          resistanceMeasurement,
          resistanceVsLength,
          seriesResistance,
          parallelResistance,
          resistivityTemperatureDependence,
        ],
      ),
      Subcategory(
        name: '電流',
        videos: [
          lemonBatteryVoltage,
          ohmsLaw,
          rcCircuit,
        ],
      ),
      Subcategory(
        name: 'ダイオード',
        videos: [
          diodeIntroduction,
        ],
      ),
      Subcategory(
        name: '磁場',
        videos: [
          // magnetometer,
          neodymiumMagnetFieldMeasurement,
          ampereLawTorque,
          straight_current_and_geomagnetism,
          magneticFieldCircularLoop,
          solenoidMagneticField,
          lorentzForce,
          forceBetweenParallelCurrents,
          neodymiumMagnetFieldMeasurement,
        ],
      ),
      Subcategory(
        name: '電磁誘導',
        videos: [
          ac_power_generation,
        ],
      ),
      Subcategory(
        name: '交流回路',
        videos: [
          capacitorReactance,
          inductorReactance,
          resistorInAC,
          rlc_circuit_discharge
        ],
      ),
      Subcategory(
        name: 'コイル',
        videos: [
          coilProperties,
          coil_self_induction_voltage,
          solenoidSelfInductance,
          mutual_inductance_coaxial_solenoids,
        ],
      ),
      Subcategory(
        name: '磁性体',
        videos: [
          bismuthDiamagnetism,
        ],
      ),
    ],
  ),

  // 波動
  Category(
    name: '波動',
    gifUrl: 'assets/init/wave.gif',
    subcategories: [
      Subcategory(
        name: '縦波横波',
        videos: [
          coupledOscillatorLongitudinal1D,
          coupledOscillatorTransverse1D,
        ],
      ),
      Subcategory(
        name: '1次元波動',
        videos: [
          waveEquation1D,
          superposition1D,
          beating1D,
        ],
      ),
      Subcategory(
        name: '2次元波動',
        videos: [
          planeWave,
          circularWave,
        ],
      ),
      Subcategory(
        name: '干渉',
        videos: [
          twoSource1D,
          planeWaveInterference,
          circularPlaneInterference,
          circularInterference,
          thinFilmInterference1D,
          thinFilmInterference2D,
        ],
      ),
      Subcategory(
        name: '屈折',
        videos: [
          refraction1D,
          refractionLaw,
        ],
      ),
      Subcategory(
        name: '反射',
        videos: [
          pulseReflection1D,
          fixedEndReflection1D,
          freeEndReflection1D,
          reflectionLaw2D,
          fixedReflection2D,
        ],
      ),
      Subcategory(
        name: 'ドップラー効果',
        videos: [
          dopplerEffect1D,
          dopplerEffectObserverMoving1D,
          dopplerEffect2D,
          dopplerEffectObserverMoving,
          movingReflector1D,
          dopplerMovingWall,
        ],
      ),
      Subcategory(
        name: '気柱の振動',
        videos: [
          closedPipeResonance,
          closedPipeWaterResonance1D,
          openPipeResonance,
        ],
      ),
      Subcategory(
        name: '弦の振動',
        videos: [
          drivenStringResonance1D,
        ],
      ),
      Subcategory(
        name: '光波',
        videos: [
          diffractionGrating,
          spectroscopy,
          youngDoubleSlit,
        ],
      ),
      Subcategory(
        name: '光の分散',
        videos: [
          rainbowDroplet2D,
          secondaryRainbowDroplet2D,
          rainbowMultiDroplet2D,
          secondaryRainbowMultiDroplet2D,
        ],
      ),
      // Subcategory(
      //   name: '音波のドップラー効果',
      //   videos: [
      //     doppler,
      //     dopplerObserverMoving
      //   ],
      // ),
      
    ],
  ),

  // 熱力学
  Category(
    name: '熱力学',
    gifUrl: 'assets/init/fire.gif',
    subcategories: [
      Subcategory(
        name: '気体の法則',
        videos: [
          boyleLaw,
          charles_s_law,
          ideal_gas_eqation_and_weight_of_air,
          ideal_gas_eqation_and_helium_buoyancy,
          isochoricProcess,
          isobaricProcess,
          isothermalProcess,
          adiabaticProcess,
          heatCycleProcess,
        ],
      ),
    ],
  )
];