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
        simpleHarmonicMotionSolution
      ],
    ),
    TheorySubcategory(
      name: '剛体のつり合い',
      topics: [
        rigidBodyBalanceOfForces,
      ],
    ),
    TheorySubcategory(
      name: '等加速度直線運動',
      topics: [
        uniformAcceleration,
      ],
    ),
    TheorySubcategory(
      name: '運動量',
      topics: [
        momentum,
      ],
    ),
    TheorySubcategory(
      name: '仕事と線積分',
      topics: [
        workAndLineIntegral
      ],
    ),
    TheorySubcategory(
      name: 'エネルギー保存則',
      topics: [
        workAndEnergy,
        conservativeForce,
        surfaceGravityEnergyConservation,
        fookEnergyConservation,
        surfaceGravAndFookEnergyConservation,
        universalGravitationEnergyConserv
      ],
    ),
    TheorySubcategory(
      name: '角運動量',
      topics: [
        angularMomentumAndTorque,
      ],
    ),
    TheorySubcategory(
      name: '円運動',
      topics: [
        simplePendulum,
        conicalPendulum
      ],
    ),
    TheorySubcategory(
      name: '極座標',
      topics: [
        uniformCircularMotion,
        nonUniformCircularMotion,
        twoDimPolarCoordinatesEqOfMotion,
      ],
    ),
    TheorySubcategory(
      name: '慣性力',
      topics: [
        inertialForceParallel,
        inertialForceRotation
      ],
    ),
    TheorySubcategory(
      name: '二体問題',
      topics: [
        doubleMassPoint,
        collisionConservation,
        doubleMassPointEnergy
      ],
    ),

    TheorySubcategory(
      name: '質点系の力学',
      topics: [
        systemsOfParticles,
      ],
    ),
    TheorySubcategory(
      name: 'ケプラーの三法則',
      topics: [
        keplerFirstLaw,
        keplerSecondLaw,
        keplerThirdLaw,
      ],
    ),
  ],
  '電磁気学理論': [
    TheorySubcategory(
      name: '流束と面積分',
      topics: [
        fluxAndAreaIntegral,
      ],
    ),
    TheorySubcategory(
      name: '媒質中の電磁波',
      topics: [
        permittivity,
        permeability,
      ],
    ),
    TheorySubcategory(
      name: 'マックスウェル方程式',
      topics: [
        electoricGaussLaw,
        magneticGaussLaw,
        electromagneticInductionLaw,
        ampereMaxwellLaw
      ],
    ),
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