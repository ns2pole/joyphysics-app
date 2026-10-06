import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/mindMap/mind_map_highlight.dart';
import 'package:joyphysics/model.dart';

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

  test('english catalog uses the orig_en landscapes', () {
    final assets = MindMapCatalog.assetsForCategory(
      'dynamics',
      languageCode: 'en',
    );
    expect(assets, isNotNull);
    expect(assets!.image, 'assets/mindMap/en/dynamicsLandScope.jpeg');
    expect(assets.ocr, 'assets/mindMap/ocr/en/dynamicsLandScope.json');

    expect(
      MindMapCatalog.assetsForCategory('waves', languageCode: 'en')!.image,
      'assets/mindMap/en/waveLandScope.jpeg',
    );
    expect(
      MindMapCatalog.assetsForCategory('electroMagnetism', languageCode: 'en')!
          .image,
      'assets/mindMap/en/emTheoryLandScope.jpeg',
    );
    expect(
      MindMapCatalog.assetsForCategory('thermoDynamics', languageCode: 'en')!
          .image,
      'assets/mindMap/en/thermoDynamicsLandScope.jpeg',
    );
  });

  test('category home asset follows language', () {
    expect(
      Category.getMindMapAssetByName('力学'),
      'assets/mindMap/dynamicsLandScope.jpeg',
    );
    expect(
      Category.getMindMapAssetByName('力学', languageCode: 'en'),
      'assets/mindMap/en/dynamicsLandScope.jpeg',
    );
    expect(
      Category.getMindMapAssetByName('力学理論', languageCode: 'en'),
      'assets/mindMap/en/dynamicsLandScope.jpeg',
    );
    expect(
      Category.getMindMapAssetByName('電磁気学', languageCode: 'en'),
      'assets/mindMap/en/emTheoryLandScope.jpeg',
    );
    expect(
      Category.getMindMapAssetByName('熱力学', languageCode: 'en'),
      'assets/mindMap/en/thermoDynamicsLandScope.jpeg',
    );
    expect(
      Category.getMindMapAssetByName('波動', languageCode: 'en'),
      'assets/mindMap/en/waveLandScope.jpeg',
    );
    expect(
      Category.getMindMapAssetByName('波動'),
      'assets/mindMap/waveLandScope.jpeg',
    );
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

  group('english phrase alignment', () {
    late Map<String, List<MindMapPhrase>> slides;

    setUpAll(() {
      final raw = File('lib/mindMap/orig_en_text_map.json').readAsStringSync();
      slides = MindMapPhraseMap.parse(jsonDecode(raw));
    });

    test('japanese OCR hits map onto the matching english phrase', () {
      final dynamics = slides['dynamics']!;
      expect(
        MindMapPhraseMap.englishQueriesFor('動摩擦力', dynamics),
        ['kinetic friction'],
      );
      expect(
        MindMapPhraseMap.englishQueriesFor('等速円運動', dynamics),
        ['uniform circular motion'],
      );
      expect(
        MindMapPhraseMap.englishQueriesFor('非等速円運動', dynamics),
        ['non-uniform circular motion'],
      );
      expect(
        MindMapPhraseMap.englishQueriesFor('フックの法則', dynamics),
        ["Hooke's law"],
      );
      expect(
        MindMapPhraseMap.englishQueriesFor('例：フックの法則の力', dynamics),
        ["e.g. the Hooke's-law force"],
      );

      final waves = slides['waves']!;
      expect(
        MindMapPhraseMap.englishQueriesFor('自由端反射', waves),
        ['reflection at a free end'],
      );
      expect(
        MindMapPhraseMap.englishQueriesFor('固定端反射', waves),
        ['reflection at a fixed end'],
      );
      expect(
        MindMapPhraseMap.englishQueriesFor('ドップラー効果', waves),
        ['Doppler effect'],
      );
      expect(
        MindMapPhraseMap.englishQueriesFor('回折格子', waves),
        ['diffraction grating'],
      );
    });
  });

  group('english overview highlight', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('japanese locale still highlights the japanese overview', () async {
      final data = await MindMapHighlightResolver.instance.resolve(
        category: 'dynamics',
        title: '等速円運動',
      );
      expect(data, isNotNull);
      expect(data!.imageAsset, 'assets/mindMap/dynamicsLandScope.jpeg');
      expect(data.matchedTexts, contains('等速円運動'));
      expect(data.matchedTexts, isNot(contains('非等速円運動')));
    });

    test('english locale highlights the english overview', () async {
      final uniform = await MindMapHighlightResolver.instance.resolve(
        category: 'dynamics',
        title: '等速円運動',
        languageCode: 'en',
      );
      expect(uniform, isNotNull);
      expect(
        uniform!.imageAsset,
        'assets/mindMap/en/dynamicsLandScope.jpeg',
      );
      final uniformText = uniform.matchedTexts.join(' ').toLowerCase();
      expect(uniformText, contains('uniform circular'));
      expect(uniformText, isNot(contains('non-uniform')));

      final nonUniform = await MindMapHighlightResolver.instance.resolve(
        category: 'dynamics',
        title: '非等速円運動',
        languageCode: 'en',
      );
      expect(
        nonUniform!.matchedTexts.join(' ').toLowerCase(),
        contains('non-uniform circular'),
      );

      final twoBody = await MindMapHighlightResolver.instance.resolve(
        category: 'dynamics',
        title: '2体問題',
        languageCode: 'en',
      );
      expect(
        twoBody!.matchedTexts.join(' ').toLowerCase(),
        contains('two-body'),
      );

      final friction = await MindMapHighlightResolver.instance.resolve(
        category: 'dynamics',
        title: '水平面上の動摩擦力',
        languageCode: 'en',
      );
      expect(friction, isNotNull);
      expect(
        friction!.imageAsset,
        'assets/mindMap/en/dynamicsLandScope.jpeg',
      );
      expect(
        friction.rects.any((r) {
          final cx = r.left + r.width / 2;
          final cy = r.top + r.height / 2;
          return (cx - 0.283).abs() < 0.08 && (cy - 0.613).abs() < 0.08;
        }),
        isTrue,
      );

      final hooke = await MindMapHighlightResolver.instance.resolve(
        category: 'dynamics',
        title: '水平バネ',
        languageCode: 'en',
      );
      final hookeText = hooke!.matchedTexts.join(' ').toLowerCase();
      expect(hookeText, contains('hooke'));
      expect(
        hooke.rects.every((r) => r.top + r.height / 2 < 0.8),
        isTrue,
      );
    });

    test('free-end and fixed-end reflections stay distinct in english', () async {
      final free = await MindMapHighlightResolver.instance.resolve(
        category: 'waves',
        title: '自由端反射',
        languageCode: 'en',
      );
      final fixed = await MindMapHighlightResolver.instance.resolve(
        category: 'waves',
        title: '固定端反射',
        languageCode: 'en',
      );
      expect(free!.imageAsset, 'assets/mindMap/en/waveLandScope.jpeg');
      expect(
        free.matchedTexts.join(' ').toLowerCase(),
        contains('free end'),
      );
      expect(
        fixed!.matchedTexts.join(' ').toLowerCase(),
        contains('fixed end'),
      );
      expect(
        fixed.matchedTexts.join(' ').toLowerCase(),
        isNot(contains('free end')),
      );
    });

    test('doppler and boyle land on the english labels', () async {
      final doppler = await MindMapHighlightResolver.instance.resolve(
        category: 'waves',
        title: 'ドップラー効果',
        languageCode: 'en',
      );
      expect(
        doppler!.matchedTexts.join(' ').toLowerCase(),
        contains('doppler'),
      );
      expect(doppler.imageAsset, contains('/en/'));

      final boyle = await MindMapHighlightResolver.instance.resolve(
        category: 'thermoDynamics',
        title: 'ボイルの法則',
        languageCode: 'en',
      );
      expect(
        boyle!.matchedTexts.join(' ').toLowerCase(),
        contains("boyle"),
      );
      expect(
        boyle.imageAsset,
        'assets/mindMap/en/thermoDynamicsLandScope.jpeg',
      );
    });
  });
}
