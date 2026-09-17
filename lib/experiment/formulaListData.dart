import 'package:joyphysics/model.dart';
import 'package:joyphysics/dataExporter.dart';
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/HexColor.dart';

final List<FormulaEntry> formulaListData = [
  FormulaEntry(
    latex: "f = \\rho g V",
    relatedVideo: buoyancyAndActionReaction,
    categoryName: "浮力・圧力",
  ),
  FormulaEntry(
    latex: "\\overrightarrow{F}_{1 \\leftarrow 2} + \\overrightarrow{F}_{2 \\leftarrow 1} = \\overrightarrow{0}",
    relatedVideo: buoyancyAndActionReaction,
    categoryName: "運動の第3法則",
  ),
  FormulaEntry(
    latex: "p = p_{0} + \\rho g h",
    relatedVideo: barometer,
    categoryName: "浮力・圧力",
  ),
  FormulaEntry(
    latex: "x(t) = \\frac12 g t^2",
    relatedVideo: freeFall,
    categoryName: "自由落下",
  ),
  FormulaEntry(
    latex: "t(x) = \\sqrt{\\frac{2x}{g}}",
    relatedVideo: freeFall,
    categoryName: "自由落下",
  ),
  FormulaEntry(
    latex: "F(x) = -k x",
    relatedVideo: verticalSpringOscillation,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "T = 2\\pi \\sqrt{\\frac{m}{k}}",
    relatedVideo: verticalSpringOscillation,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "F_{s} = \\mu_{s} N",
    relatedVideo: staticFriction,
    categoryName: "摩擦力",
  ),
  FormulaEntry(
    latex: "F_{k} = \\mu_{k} N",
    relatedVideo: kineticFriction,
    categoryName: "摩擦力",
  ),
  FormulaEntry(
    latex: "T = 2\\pi \\sqrt{\\frac{l}{g}}",
    relatedVideo: pendulumPeriodMeasurement,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "m_{1} v_{1} + m_{2} v_{2} = m_{1} v_{1}' + m_{2} v_{2}'",
    relatedVideo: elasticCollision1D,
    categoryName: "弾性衝突",
  ),
  FormulaEntry(
    latex: "m_{1} \\vec{v}_{1} + m_{2} \\vec{v}_{2} = m_{1} \\vec{v}_{1}' + m_{2} \\vec{v}_{2}'",
    relatedVideo: elasticCollision2D,
    categoryName: "弾性衝突",
  ),
  FormulaEntry(
    latex: "\\tfrac12 m_{1} v_{1}^{2} + \\tfrac12 m_{2} v_{2}^{2} = \\tfrac12 m_{1} v_{1}'^{2} + \\tfrac12 m_{2} v_{2}'^{2}",
    relatedVideo: elasticCollision2D,
    categoryName: "弾性衝突",
  ),
  FormulaEntry(
    latex: "\\frac{T^{2}}{a^{3}} = \\frac{4\\pi^{2}}{GM}",
    relatedVideo: planets,
    categoryName: "ケプラーの第3法則",
  ),
  FormulaEntry(
    latex: "F = q v B \\sin\\theta",
    relatedVideo: lorentzForce,
    categoryName: "電磁力・ローレンツ力",
  ),
  FormulaEntry(
    latex: "F = I \\ell B \\sin\\theta",
    relatedVideo: lorentzForce,
    categoryName: "電磁力・ローレンツ力",
  ),
  FormulaEntry(
    latex: "B = \\dfrac{\\mu_{0} I}{2\\pi r}",
    relatedVideo: ampereLawTorque,
    categoryName: "磁場",
  ),
  FormulaEntry(
    latex: "B = \\dfrac{\\mu_{0} I}{2a}",
    relatedVideo: magneticFieldCircularLoop,
    categoryName: "磁場",
  ),
  FormulaEntry(
    latex: "B = \\mu n I",
    relatedVideo: solenoidMagneticField,
    categoryName: "磁場",
  ),
  FormulaEntry(
    latex: "F = \\dfrac{\\mu_{0} I_{1} I_{2} \\ell}{2\\pi r}",
    relatedVideo: forceBetweenParallelCurrents,
    categoryName: "電磁力・ローレンツ力",
  ),
  FormulaEntry(
    latex: "L = \\mu_{0} \\mu_{r} \\dfrac{N^{2} A}{\\ell}",
    relatedVideo: solenoidSelfInductance,
    categoryName: "電磁誘導・インダクタンス",
  ),
  FormulaEntry(
    latex: "R = \\rho \\dfrac{\\ell}{A}",
    relatedVideo: resistanceVsLength,
    categoryName: "電流",
  ),
  FormulaEntry(
    latex: "V = RI",
    relatedVideo: ohmsLaw,
    categoryName: "電流",
  ),
  FormulaEntry(
    latex: "R = \\sum_{i=1}^{n} R_{i}",
    relatedVideo: seriesResistance,
    categoryName: "電流",
  ),
  FormulaEntry(
    latex: "\\dfrac{1}{R} = \\sum_{i=1}^{n} \\dfrac{1}{R_{i}}",
    relatedVideo: parallelResistance,
    categoryName: "電流",
  ),
  FormulaEntry(
    latex: "R = R_{0} \\bigl(1 + \\alpha (T - T_{0})\\bigr)",
    relatedVideo: resistivityTemperatureDependence,
    categoryName: "電流",
  ),
  FormulaEntry(
    latex: "C = \\varepsilon_{0} \\dfrac{S}{d}",
    relatedVideo: parallelPlateCapacitanceMeasurement,
    categoryName: "コンデンサ・静電気",
  ),
  FormulaEntry(
    latex: "\\dfrac{1}{C} = \\sum_{i=1}^{n} \\dfrac{1}{C_{i}}",
    relatedVideo: capacitanceSeriesCombination,
    categoryName: "コンデンサ・静電気",
  ),
  FormulaEntry(
    latex: "C = \\sum_{i=1}^{n} C_{i}",
    relatedVideo: capacitanceParallelCombination,
    categoryName: "コンデンサ・静電気",
  ),
  FormulaEntry(
    latex: "Q = CV",
    relatedVideo: capacitorChargeStorage,
    categoryName: "コンデンサ・静電気",
  ),
  FormulaEntry(
    latex: "L = \\frac{(2n-1)\\lambda}{4} （n=1,3,5,\\cdots）",
    relatedVideo: closedPipeResonance,
    categoryName: "音の共鳴",
  ),
  FormulaEntry(
    latex: "L = \\frac{n\\lambda}{2} （n=1,2,3,\\cdots）",
    relatedVideo: openPipeResonance,
    categoryName: "音の共鳴",
  ),
  FormulaEntry(
    latex: "f = \\bigl| f_1 - f_2 \\bigr| ",
    relatedVideo: beat,
    categoryName: "うなり",
  ),
  FormulaEntry(
    latex: "f' = f  \\frac{v \\pm v_{\\text{観測者}}}{v}",
      relatedVideo: dopplerObserverMoving,
      categoryName: "ドップラー効果",
  ),
  FormulaEntry(
    latex: "f' = f  \\frac{v \\mp v_{\\text{音源}}}{v} ",
      relatedVideo: doppler,
      categoryName: "ドップラー効果",
  ),
  FormulaEntry(
    latex: "d \\sin\\theta = n\\lambda",
    relatedVideo: diffractionGrating,
    categoryName: "光の干渉・回折",
  ),
  FormulaEntry(
    latex: "PV = \\text{一定}",
    relatedVideo: boyleLaw,
    categoryName: "気体の法則・熱力学",
  ),
];