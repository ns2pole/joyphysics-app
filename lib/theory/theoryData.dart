import 'package:joyphysics/dataExporter.dart';
import 'package:joyphysics/model.dart';

final Map<String, List<TheorySubcategory>> theoryData = {
  '物理のための数学': [
    TheorySubcategory(
      name: 'ベクトル',
      topics: [
        vectorComponent,
      ],
    ),
    // TheorySubcategory(
    //   name: '微分方程式',
    //   topics: [
    //     harmonic,
    //   ],
    // ),
  ],
  '力学理論': [
    TheorySubcategory(
      name: '運動方程式',
      topics: [
        eqOfMotion,
      ],
    ),
    TheorySubcategory(
      name: '運動量',
      topics: [
        momentum,
      ],
    ),
    TheorySubcategory(
      name: '仕事とエネルギー',
      topics: [
        workAndEnergy,
      ],
    ),
    TheorySubcategory(
      name: '等加速度直線運動',
      topics: [
        uniformAcceleration,
      ],
    ),
    TheorySubcategory(
      name: 'ケプラー問題',
      topics: [
        universalGravitationEnergyConserv,
        keplerFirstLaw,
        keplerSecondLaw,
        keplerThirdLaw,
      ],
    ),
  ],
  '電磁気学理論': [
  //   // TheorySubcategory(
  //   //   name: '電場と電位',
  //   //   topics: [
  //   //     gaussLaw,
  //   //   ],
  //   // ),
    TheorySubcategory(
      name: '磁場と電流',
      topics: [
        // ampereLaw,
        lorentzForceAndCircleMove,
        infiniteStraightCurrent,
        solenoidMagneticFieldProp
      ],
    ),
  ],
};