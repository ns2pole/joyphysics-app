import 'dart:io' show Platform;
import 'package:joyphysics/model.dart';
import 'package:joyphysics/dataExporter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final categoriesData = <Category>[
  // 力学
  Category(
    name: '力学実験',
    gifUrl: 'assets/init/dynamics.gif',
    subcategories: [
      Subcategory(        
        name: '加速度センサー',
        videos: [
          accelerometer
        ],
      ),
      Subcategory(
        name: '色々な力',
        videos: [
          fook,
          staticFriction,
          kineticFriction,
          buoyancyAndActionReaction,
          buoyancyComparison,
          barometer
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
    name: '電磁気学実験',
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
          magnetometer,
          neodymiumMagnetFieldMeasurement,
          ampereLawTorque,
          magneticFieldCircularLoop,
          solenoidMagneticField,
          lorentzForce,
          forceBetweenParallelCurrents,
          neodymiumMagnetFieldMeasurement,
        ],
      ),
      Subcategory(
        name: 'コイルの性質',
        videos: [
          coilProperties,
          solenoidSelfInductance,
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
    name: '波動実験',
    gifUrl: 'assets/init/wave.gif',
    subcategories: [
      Subcategory(
        name: '音波',
        videos: [
          frequencyMeasurement,
          closedPipeResonance,
          openPipeResonance,
          beat,
          doppler,
          frequencyAndDoReMi,
          dopplerObserverMoving
        ],
      ),
      Subcategory(
        name: '光波',
        videos: [
          diffractionGrating,
          spectroscopy,
          if (!(kIsWeb || Platform.isIOS)) luxMeasurement,
        ],
      )
    ],
  ),

  // 熱力学
  Category(
    name: '熱力学実験',
    gifUrl: 'assets/init/fire.gif',
    subcategories: [
      Subcategory(
        name: '気体の法則',
        videos: [
          boyleLaw,
        ],
      ),
    ],
  )
];