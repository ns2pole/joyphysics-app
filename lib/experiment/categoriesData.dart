import 'dart:io' show Platform;
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
        name: '色々な力',
        videos: [
          fook,
          staticFriction,
          kineticFriction,
          buoyancyAndActionReaction,
          buoyancyComparison,
          // barometer
        ],
      ),
      Subcategory(
        name: '運動方程式',
        videos: [
          freeFall,
          verticalSpringOscillation,
          pendulumPeriodMeasurement,
        ],
      ),
      Subcategory(
        name: '円運動',
        videos: [
          centripetalForceDisappears
        ],
      ),
      Subcategory(
        name: '保存則',
        videos: [
          elasticCollision1D,
          elasticCollision2D,
        ],
      ),
      Subcategory(
        name: '剛体',
        videos: [
          oneSideLift,
          buildingBlocksStability,
        ],
      ),
      Subcategory(
        name: 'ケプラーの法則',
        videos: [
          planets,
          moonOrbit,
          jupiter,
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
        name: '半導体・電子素子',
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
        name: 'コイルの性質',
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
        name: '1次元波動',
        videos: [
          waveEquation1D,
          superposition1D,
        ],
      ),
      Subcategory(
        name: '2次元空間における波動',
        videos: [
          planeWave,
          circularWave,
          circularInterference,
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
        ],
      ),
      Subcategory(
        name: '音波',
        videos: [
          soundGenerate,
          closedPipeResonance,
          openPipeResonance,
        ],
      ),
      Subcategory(
        name: '光波',
        videos: [
          diffractionGrating,
          spectroscopy,
          thinFilmInterference1D,
          thinFilmInterference2D,
          youngDoubleSlit,
        ],
      ),
      Subcategory(
        name: '物質中の波動',
        videos: [
          refraction1D,
          refractionLaw,
        ],
      ),
      Subcategory(
        name: '異媒質間における反射',
        videos: [
          pulseReflection1D,
          fixedEndReflection1D,
          freeEndReflection1D,
          reflectionLaw2D,
          fixedReflection2D,
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
          ideal_gas_eqation_and_helium_buoyancy
        ],
      ),
    ],
  )
];