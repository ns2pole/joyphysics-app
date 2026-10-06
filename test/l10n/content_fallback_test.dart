import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/model.dart';

void main() {
  group('Video localization', () {
    test('falls back to Japanese when English is missing', () {
      final video = Video(
        category: 'dynamics',
        iconName: 'x',
        title: '自由落下',
        videoURL: 'abcdEFGhi12',
        equipment: const ['糸', 'おもり'],
        costRating: '★',
        latex: '<p>日本語</p>',
      );

      expect(video.localizedTitle('en'), '自由落下');
      expect(video.localizedLatex('en'), '<p>日本語</p>');
      expect(video.localizedEquipment('en'), ['糸', 'おもり']);
      expect(video.localizedTitle('ja'), '自由落下');
    });

    test('returns English when present', () {
      final video = Video(
        category: 'dynamics',
        iconName: 'x',
        title: '自由落下',
        titleEn: 'Free fall',
        videoURL: 'abcdEFGhi12',
        equipment: const ['糸', 'おもり'],
        equipmentEn: const ['string', 'weight'],
        costRating: '★',
        latex: '<p>日本語</p>',
        latexEn: '<p>English</p>',
      );

      expect(video.localizedTitle('en'), 'Free fall');
      expect(video.localizedLatex('en'), '<p>English</p>');
      expect(video.localizedEquipment('en'), ['string', 'weight']);
      expect(video.localizedTitle('ja'), '自由落下');
    });

    test('equipmentEn length must match to be used', () {
      final video = Video(
        category: 'dynamics',
        iconName: 'x',
        title: '自由落下',
        videoURL: 'abcdEFGhi12',
        equipment: const ['糸', 'おもり'],
        equipmentEn: const ['string'],
        costRating: '★',
      );

      expect(video.hasEnglishEquipment, isFalse);
      expect(video.localizedEquipment('en'), ['糸', 'おもり']);
    });

    test('localizedVideoURL prefers English when present', () {
      final video = Video(
        category: 'waves',
        iconName: 'x',
        title: '回折格子(単色光)',
        videoURL: 'meaeB8JV4qw',
        videoURLEn: '9ZzSZD9r8ug',
        equipment: const [],
        costRating: '★',
      );

      expect(video.localizedVideoURL('en'), '9ZzSZD9r8ug');
      expect(video.localizedVideoURL('ja'), 'meaeB8JV4qw');
    });

    test('localizedVideoURL falls back to Japanese when English is missing', () {
      final video = Video(
        category: 'waves',
        iconName: 'x',
        title: '回折格子(単色光)',
        videoURL: 'meaeB8JV4qw',
        equipment: const [],
        costRating: '★',
      );

      expect(video.localizedVideoURL('en'), 'meaeB8JV4qw');
    });

    test('EN hides JP-only YouTube articles; keeps simulations and bilingual', () {
      final jpOnlyVideo = Video(
        category: 'dynamics',
        iconName: 'x',
        title: '日本語のみ動画',
        videoURL: 'abcdEFGhi12',
        equipment: const [],
        costRating: '★',
      );
      final bilingual = Video(
        category: 'dynamics',
        iconName: 'x',
        title: '二言語',
        videoURL: 'abcdEFGhi12',
        videoURLEn: 'abcdEFGhi12',
        equipment: const [],
        costRating: '★',
      );
      final simulation = Video(
        category: 'dynamics',
        iconName: 'x',
        title: 'シミュレーション',
        videoURL: '',
        equipment: const [],
        costRating: '★',
        experimentWidgets: const [],
        isSimulation: true,
      );

      expect(jpOnlyVideo.isAvailableForLanguage('ja'), isTrue);
      expect(jpOnlyVideo.isAvailableForLanguage('en'), isFalse);
      expect(bilingual.isAvailableForLanguage('en'), isTrue);
      // No playable JP YouTube → not hidden on EN (simulations / widget-only).
      expect(simulation.hasPlayableJapaneseVideo, isFalse);
      expect(simulation.isAvailableForLanguage('en'), isTrue);
    });
  });

  group('TheoryTopic language availability', () {
    test('EN hides JP-only YouTube theory topics', () {
      final jpOnly = TheoryTopic(
        title: '日本語のみ',
        latexContent: r'<p>ja</p>',
        videoURL: 'abcdEFGhi12',
      );
      final bilingual = TheoryTopic(
        title: '二言語',
        latexContent: r'<p>ja</p>',
        videoURL: 'abcdEFGhi12',
        videoURLEn: 'abcdEFGhi12',
      );
      final noVideo = TheoryTopic(
        title: '動画なし',
        latexContent: r'<p>ja</p>',
      );

      expect(jpOnly.isAvailableForLanguage('en'), isFalse);
      expect(bilingual.isAvailableForLanguage('en'), isTrue);
      expect(noVideo.isAvailableForLanguage('en'), isTrue);
    });
  });

  group('TheoryTopic localization', () {
    test('falls back and prefers English correctly', () {
      final topic = TheoryTopic(
        title: '仕事とエネルギー',
        titleEn: 'Work and energy',
        latexContent: r'<p>日本語</p>',
        latexContentEn: r'<p>English</p>',
      );

      expect(topic.localizedTitle('en'), 'Work and energy');
      expect(topic.localizedLatexContent('en'), r'<p>English</p>');
      expect(topic.localizedTitle('ja'), '仕事とエネルギー');

      final jaOnly = TheoryTopic(
        title: '仕事とエネルギー',
        latexContent: r'<p>日本語</p>',
      );
      expect(jaOnly.localizedTitle('en'), '仕事とエネルギー');
      expect(jaOnly.localizedLatexContent('en'), r'<p>日本語</p>');
    });
  });
}
