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
    latex: "y = v_{0} t - \\frac{1}{2} g t^{2}",
    relatedVideo: verticalThrow1D,
    categoryName: "鉛直投げ上げ",
  ),
  FormulaEntry(
    latex: "v = v_{0} - g t",
    relatedVideo: verticalThrow1D,
    categoryName: "鉛直投げ上げ",
  ),
  FormulaEntry(
    latex: "H = \\frac{v_{0}^{2}}{2g}",
    relatedVideo: verticalThrow1D,
    categoryName: "鉛直投げ上げ",
  ),
  FormulaEntry(
    latex: "y = h + (v_{0}\\sin\\theta)t - \\frac{1}{2}gt^{2}",
    relatedVideo: projectileMotion2D,
    categoryName: "斜方投射",
  ),
  FormulaEntry(
    latex: "T = \\frac{v_{0}\\sin\\theta + \\sqrt{(v_{0}\\sin\\theta)^{2}+2gh}}{g}",
    relatedVideo: projectileMotion2D,
    categoryName: "斜方投射",
  ),
  FormulaEntry(
    latex: "H = h + \\frac{(v_{0}\\sin\\theta)^{2}}{2g}\\quad(\\theta>0)",
    relatedVideo: projectileMotion2D,
    categoryName: "斜方投射",
  ),
  FormulaEntry(
    latex: "\\displaystyle v'=-ev",
    relatedVideo: bounce1D,
    categoryName: "衝突",
  ),
  FormulaEntry(
    latex: "\\displaystyle H'=e^{2}H",
    relatedVideo: bounce1D,
    categoryName: "衝突",
  ),
  FormulaEntry(
    latex: "\\displaystyle v_{y}'=-ev_{y}",
    relatedVideo: bounce2D,
    categoryName: "衝突",
  ),
  FormulaEntry(
    latex: "T = 2\\pi \\sqrt{\\frac{h}{g}}",
    relatedVideo: floatingOscillation1D,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "F(x) = -k x",
    relatedVideo: horizontalSpring1D,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "x = A \\cos\\omega t",
    relatedVideo: horizontalSpring1D,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "\\omega = \\sqrt{\\frac{k}{m}}",
    relatedVideo: horizontalSpring1D,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "\\displaystyle m\\ddot{x}=-kx-\\mu' mg\\,\\mathrm{sgn}(v)",
    relatedVideo: roughHorizontalSpring1D,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "\\displaystyle |x|\\le \\frac{\\mu mg}{k}",
    relatedVideo: roughHorizontalSpring1D,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "\\delta = \\frac{mg}{k}",
    relatedVideo: verticalSpring1D,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "T = 2\\pi \\sqrt{\\frac{m}{k}}",
    relatedVideo: verticalSpringOscillation,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "\\mu \\ddot{R} = -k(R-\\ell)",
    relatedVideo: twoBodySpring1D,
    categoryName: "2体問題",
  ),
  FormulaEntry(
    latex: "T = 2\\pi \\sqrt{\\frac{\\mu}{k}}",
    relatedVideo: twoBodySpring1D,
    categoryName: "2体問題",
  ),
  FormulaEntry(
    latex: "a = a_1 + a_2",
    relatedVideo: twoBodyKepler2D,
    categoryName: "2体問題",
  ),
  FormulaEntry(
    latex: "\\frac{m_1}{m_2} = \\frac{a_2}{a_1}",
    relatedVideo: twoBodyKepler2D,
    categoryName: "2体問題",
  ),
  FormulaEntry(
    latex: "\\frac{T^{2}}{a^{3}} = \\frac{4\\pi^{2}}{G(m_1+m_2)}",
    relatedVideo: twoBodyKepler2D,
    categoryName: "2体問題",
  ),
  FormulaEntry(
    latex: "a = \\frac{v^{2}}{R}",
    relatedVideo: uniformCircularMotion2D,
    categoryName: "円運動",
  ),
  FormulaEntry(
    latex: "T = \\frac{2\\pi R}{v}",
    relatedVideo: uniformCircularMotion2D,
    categoryName: "円運動",
  ),
  FormulaEntry(
    latex: "F = m\\frac{v^{2}}{R}",
    relatedVideo: uniformCircularMotion2D,
    categoryName: "円運動",
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
    latex: "\\displaystyle v=v_{0}-\\mu g t",
    relatedVideo: kineticFriction1D,
    categoryName: "摩擦力",
  ),
  FormulaEntry(
    latex: "\\displaystyle x=v_{0}t-\\frac{1}{2}\\mu g t^{2}",
    relatedVideo: kineticFriction1D,
    categoryName: "摩擦力",
  ),
  FormulaEntry(
    latex: "\\displaystyle x=\\frac{v_{0}^{2}}{2\\mu g}",
    relatedVideo: kineticFriction1D,
    categoryName: "摩擦力",
  ),
  FormulaEntry(
    latex: "\\displaystyle a=g(\\sin\\theta-\\mu\\cos\\theta)",
    relatedVideo: kineticFrictionIncline1D,
    categoryName: "摩擦力",
  ),
  FormulaEntry(
    latex: "\\displaystyle s=v_{0}t+\\frac{1}{2}at^{2}",
    relatedVideo: kineticFrictionIncline1D,
    categoryName: "摩擦力",
  ),
  FormulaEntry(
    latex: "\\displaystyle s=\\frac{v_{0}^{2}}{2g(\\mu\\cos\\theta-\\sin\\theta)}",
    relatedVideo: kineticFrictionIncline1D,
    categoryName: "摩擦力",
  ),
  FormulaEntry(
    latex: "\\displaystyle a=-g-kv",
    relatedVideo: linearDrag1D,
    categoryName: "空気抵抗",
  ),
  FormulaEntry(
    latex: "\\displaystyle v_t=\\frac{g}{k}",
    relatedVideo: linearDrag1D,
    categoryName: "空気抵抗",
  ),
  FormulaEntry(
    latex: "\\displaystyle v=-v_t+(v_0+v_t)e^{-kt}",
    relatedVideo: linearDrag1D,
    categoryName: "空気抵抗",
  ),
  FormulaEntry(
    latex: "\\displaystyle a=\\frac{(m_1-m_2)g}{m_1+m_2}",
    relatedVideo: atwoodMachine1D,
    categoryName: "滑車",
  ),
  FormulaEntry(
    latex: "\\displaystyle T=\\frac{2m_1 m_2 g}{m_1+m_2}",
    relatedVideo: atwoodMachine1D,
    categoryName: "滑車",
  ),
  FormulaEntry(
    latex: "\\displaystyle s=\\frac{1}{2}at^{2}",
    relatedVideo: atwoodMachine1D,
    categoryName: "滑車",
  ),
  FormulaEntry(
    latex: "\\displaystyle \\alpha=\\frac{(2M-m)g}{m+4M}",
    relatedVideo: movablePulley1D,
    categoryName: "滑車",
  ),
  FormulaEntry(
    latex: "\\displaystyle \\beta=2\\alpha",
    relatedVideo: movablePulley1D,
    categoryName: "滑車",
  ),
  FormulaEntry(
    latex: "\\displaystyle T=\\frac{3mMg}{m+4M}",
    relatedVideo: movablePulley1D,
    categoryName: "滑車",
  ),
  FormulaEntry(
    latex: "\\displaystyle A=\\frac{mg\\sin\\theta\\cos\\theta}{M+m\\sin^{2}\\theta}",
    relatedVideo: movableWedge1D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle L=\\frac{ml\\cos\\theta}{M+m}",
    relatedVideo: movableWedge1D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle T=m(g+a)",
    relatedVideo: elevatorInertial1D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle T=m(g-a)",
    relatedVideo: elevatorInertial1D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle \\tan a=\\frac{A}{g}",
    relatedVideo: trainPendulumInertial2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle T=m\\sqrt{g^{2}+A^{2}}",
    relatedVideo: trainPendulumInertial2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle T_{\\mathrm{周期}}=2\\pi\\sqrt{\\frac{l}{\\sqrt{g^{2}+A^{2}}}}",
    relatedVideo: trainPendulumInertial2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle T=m\\frac{v^{2}}{R}",
    relatedVideo: centrifugalForce2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle m\\omega^{2}R=m\\frac{v^{2}}{R}",
    relatedVideo: centrifugalForce2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle F_{\\mathrm{cen}}=m\\Omega^{2}R",
    relatedVideo: coriolisCentripetal2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle F_{\\mathrm{Cor}}=-2m\\Omega^{2}R",
    relatedVideo: coriolisCentripetal2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle F_{\\mathrm{cen}}+F_{\\mathrm{Cor}}=-m\\Omega^{2}R",
    relatedVideo: coriolisCentripetal2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle \\tilde{x}=(y_{0}+vt)\\sin\\omega t",
    relatedVideo: coriolisSpiral2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle \\tilde{y}=(y_{0}+vt)\\cos\\omega t",
    relatedVideo: coriolisSpiral2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle r=\\lvert y_{0}+vt\\rvert",
    relatedVideo: coriolisSpiral2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle \\omega=\\alpha t",
    relatedVideo: eulerForce2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle \\theta=\\frac{1}{2}\\alpha t^{2}",
    relatedVideo: eulerForce2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "\\displaystyle F_{\\mathrm{E}}=m\\alpha R",
    relatedVideo: eulerForce2D,
    categoryName: "慣性力",
  ),
  FormulaEntry(
    latex: "T = 2\\pi \\sqrt{\\frac{l}{g}}",
    relatedVideo: pendulumPeriodMeasurement,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "m_{1} v_{1} + m_{2} v_{2} = m_{1} v_{1}' + m_{2} v_{2}'",
    relatedVideo: elasticCollision1D,
    categoryName: "衝突",
  ),
  FormulaEntry(
    latex: "\\displaystyle v_{m}'=\\frac{m-eM}{m+M}v",
    relatedVideo: collision1D,
    categoryName: "衝突",
  ),
  FormulaEntry(
    latex: "\\displaystyle v_{M}'=\\frac{(1+e)m}{m+M}v",
    relatedVideo: collision1D,
    categoryName: "衝突",
  ),
  FormulaEntry(
    latex: "\\displaystyle e=\\frac{v_{M}'-v_{m}'}{v}",
    relatedVideo: collision1D,
    categoryName: "衝突",
  ),
  FormulaEntry(
    latex: "m_{1} \\vec{v}_{1} + m_{2} \\vec{v}_{2} = m_{1} \\vec{v}_{1}' + m_{2} \\vec{v}_{2}'",
    relatedVideo: elasticCollision2D,
    categoryName: "衝突",
  ),
  FormulaEntry(
    latex: "\\tfrac12 m_{1} v_{1}^{2} + \\tfrac12 m_{2} v_{2}^{2} = \\tfrac12 m_{1} v_{1}'^{2} + \\tfrac12 m_{2} v_{2}'^{2}",
    relatedVideo: elasticCollision2D,
    categoryName: "衝突",
  ),
  FormulaEntry(
    latex: "r = \\frac{a(1-e^{2})}{1+e\\cos\\theta}",
    relatedVideo: keplerLaws2D,
    categoryName: "ケプラーの法則",
  ),
  FormulaEntry(
    latex: "nt = u - e\\sin u",
    relatedVideo: keplerLaws2D,
    categoryName: "ケプラーの法則",
  ),
  FormulaEntry(
    latex: "\\frac{T^{2}}{a^{3}} = \\frac{4\\pi^{2}}{GM}",
    relatedVideo: keplerLaws2D,
    categoryName: "ケプラーの法則",
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
    latex: "\\omega_n = 2\\sqrt{\\frac{k}{m}}\\,\\sin\\frac{n\\pi}{2(N+1)}",
    relatedVideo: coupledOscillatorLongitudinal1D,
    categoryName: "縦波横波",
  ),
  FormulaEntry(
    latex: "\\omega_n = 2\\sqrt{\\frac{k}{m}}\\,\\sin\\frac{n\\pi}{2(N+1)}",
    relatedVideo: coupledOscillatorTransverse1D,
    categoryName: "縦波横波",
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
    latex: "u = v \\left|\\frac{f - f_{\\mathrm{ref}}}{f + f_{\\mathrm{ref}}}\\right|",
    relatedVideo: dopplerMovingWall,
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
  FormulaEntry(
    latex: "W = Q - Q'",
    relatedVideo: heatCycleProcess,
    categoryName: "気体の法則・熱力学",
  ),
  FormulaEntry(
    latex: "\\eta = \\frac{W}{Q} = 1 - \\frac{Q'}{Q}",
    relatedVideo: heatCycleProcess,
    categoryName: "気体の法則・熱力学",
  ),
];