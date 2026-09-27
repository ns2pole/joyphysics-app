import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/mindMap/mind_map_highlight.dart';

void main() {
  test('MindMapRect.padded expands and clamps', () {
    const r = MindMapRect(left: 0.1, top: 0.2, width: 0.05, height: 0.03);
    final p = r.padded(pad: 0.01);
    expect(p.left, closeTo(0.09, 1e-9));
    expect(p.top, closeTo(0.19, 1e-9));
    expect(p.width, closeTo(0.07, 1e-9));
    expect(p.height, closeTo(0.05, 1e-9));
  });

  test('catalog maps dynamics category to LandScope', () {
    final assets = MindMapCatalog.assetsForCategory('dynamics');
    expect(assets, isNotNull);
    expect(assets!.image, 'assets/mindMap/dynamicsLandScope.jpeg');
    expect(assets.ocr, 'assets/mindMap/ocr/dynamicsLandScope.json');
  });

  test('imageDestinationRect keeps image aspect inside letterbox', () {
    final dest = MindMapHighlightImage.imageDestinationRect(
      layoutSize: const Size(400, 800),
      imageSize: const Size(1920, 1080),
      fit: BoxFit.contain,
    );
    expect(dest.width, closeTo(400, 0.1));
    expect(dest.height, closeTo(225, 0.1));
    expect(dest.top, closeTo((800 - 225) / 2, 0.1));
  });

  group('title keyword OCR match', () {
    const dynamicsOcr = [
      '力の釣り合い',
      '動摩擦力',
      '例：静止摩擦力，浮力',
      '作用反作用の法則',
      '等速円運動',
      '非等速円運動',
      '遠心力、コリオリの力、オイラーカ',
      '等速直線運動',
      '変位に比例する力く→三角関数解（単振動）',
      '2体問題',
      '（ガリレオ）',
      'ケプラーの第3法則',
    ];

    test('動摩擦力 titles hit 動摩擦力, not 力の釣り合い', () {
      for (final title in [
        '動摩擦力と動摩擦係数',
        '水平面上の動摩擦力',
        '斜面上の動摩擦力',
      ]) {
        final hits =
            MindMapHighlightResolver.titleKeywordMatches(title, dynamicsOcr);
        expect(hits, contains('動摩擦力'));
        expect(hits, isNot(contains('力の釣り合い')));
      }
    });

    test('静止摩擦力 hits 例：静止摩擦力，浮力', () {
      final hits = MindMapHighlightResolver.titleKeywordMatches(
        '静止摩擦力と静止摩擦係数',
        dynamicsOcr,
      );
      expect(hits, contains('例：静止摩擦力，浮力'));
      expect(hits, isNot(contains('力の釣り合い')));
    });

    test('等速円運動 does not also highlight 非等速円運動', () {
      final hits = MindMapHighlightResolver.titleKeywordMatches(
        '等速円運動',
        dynamicsOcr,
      );
      expect(hits, contains('等速円運動'));
      expect(hits, isNot(contains('非等速円運動')));
    });

    test('paren condition 等速直線運動 is ignored when outer keywords hit', () {
      final hits = MindMapHighlightResolver.titleKeywordMatches(
        '遠心力とコリオリ力(等速直線運動)',
        dynamicsOcr,
      );
      expect(hits, contains('遠心力、コリオリの力、オイラーカ'));
      expect(hits, isNot(contains('等速直線運動')));
    });

    test('timeline-only （ガリレオ） is ignored', () {
      final hits = MindMapHighlightResolver.titleKeywordMatches(
        '木星のガリレオ衛星とケプラー第3法則',
        dynamicsOcr,
      );
      expect(hits, isNot(contains('（ガリレオ）')));
    });
  });
}
