import 'package:flutter/material.dart';

// データモデル
class Video {
  final bool? isNew;
  final bool? inPreparation;
  final String category;
  final String iconName;
  final String title;
  final String? titleEn;
  final String videoURL;
  /// English YouTube ID/URL when the JP experiment video has a translated counterpart.
  final String? videoURLEn;
  final List<String> equipment;
  final List<String>? equipmentEn;
  final String costRating;
  final bool? isSmartPhoneOnly;
  final bool? isSimulation; // シミュレーション・アニメーションかどうか
  final bool? isExperiment; // 実験かどうか
  final bool playsSound;
  final bool warnsHighPitchSound;
  final String? latex;
  final String? latexEn;
  final List<Widget>? experimentWidgets; // 複数のWidgetを許可
  /// 全体像 OCR マッチ用。原則は [title] から自動照合するので不要。
  /// タイトルと全体像の文言が違うときだけ上書きする（例: `'2体問題'`）。
  final String? mindMapQuery;

  Video({
    this.isNew,
    this.inPreparation = false,
    required this.category,
    required this.iconName,
    required this.title,
    this.titleEn,
    required this.videoURL,
    this.videoURLEn,
    required this.equipment,
    this.equipmentEn,
    required this.costRating,
    this.isSmartPhoneOnly,
    this.isSimulation,
    this.isExperiment,
    this.playsSound = false,
    this.warnsHighPitchSound = false,
    this.latex,
    this.latexEn,
    this.experimentWidgets, // ← optional, default null
    this.mindMapQuery,
  });

  String get assetPath => 'assets/$category/$iconName.png';

  Image getImage() => Image.asset(assetPath);

  bool get hasEnglishTitle => titleEn != null && titleEn!.trim().isNotEmpty;

  bool get hasEnglishLatex => latexEn != null && latexEn!.trim().isNotEmpty;

  bool get hasEnglishEquipment =>
      equipmentEn != null && equipmentEn!.length == equipment.length;

  bool get hasEnglishVideoURL =>
      videoURLEn != null && videoURLEn!.trim().isNotEmpty;

  String localizedTitle(String languageCode) {
    if (languageCode == 'en' && hasEnglishTitle) return titleEn!;
    return title;
  }

  String? localizedLatex(String languageCode) {
    if (languageCode == 'en' && hasEnglishLatex) return latexEn;
    return latex;
  }

  List<String> localizedEquipment(String languageCode) {
    if (languageCode == 'en' && hasEnglishEquipment) return equipmentEn!;
    return equipment;
  }

  String localizedVideoURL(String languageCode) {
    if (languageCode == 'en' && hasEnglishVideoURL) return videoURLEn!;
    return videoURL;
  }

  /// True when [videoURL] looks like a real YouTube id/URL (not empty/placeholder).
  bool get hasPlayableJapaneseVideo {
    final raw = videoURL.trim();
    if (raw.isEmpty || raw == '（動画URLをここに）' || raw.contains('（動画URL')) {
      return false;
    }
    final id = extractVideoId(raw);
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id);
  }

  /// English locale hides JP-only YouTube articles; simulations (no video) stay.
  bool isAvailableForLanguage(String languageCode) {
    if (languageCode != 'en') return true;
    if (hasPlayableJapaneseVideo && !hasEnglishVideoURL) return false;
    return true;
  }
}

class TheoryTopic {
  final String title;
  final String? titleEn;
  final String latexContent;
  final String? latexContentEn;
  final String? videoURL;
  final String? videoURLEn;
  final bool? inPreparation;
  final bool isNew;
  final String? imageAsset; // ここを追加

  TheoryTopic({
    required this.title,
    this.titleEn,
    required this.latexContent,
    this.latexContentEn,
    this.videoURL,
    this.videoURLEn,
    this.isNew = false,
    this.inPreparation = false,
    this.imageAsset, // コンストラクタにも追加
  });

  bool get hasEnglishTitle => titleEn != null && titleEn!.trim().isNotEmpty;

  bool get hasEnglishLatex =>
      latexContentEn != null && latexContentEn!.trim().isNotEmpty;

  bool get hasEnglishVideoURL =>
      videoURLEn != null && videoURLEn!.trim().isNotEmpty;

  String localizedTitle(String languageCode) {
    if (languageCode == 'en' && hasEnglishTitle) return titleEn!;
    return title;
  }

  String localizedLatexContent(String languageCode) {
    if (languageCode == 'en' && hasEnglishLatex) return latexContentEn!;
    return latexContent;
  }

  String? localizedVideoURL(String languageCode) {
    if (languageCode == 'en' && hasEnglishVideoURL) return videoURLEn;
    return videoURL;
  }

  bool get hasPlayableJapaneseVideo {
    final raw = (videoURL ?? '').trim();
    if (raw.isEmpty) return false;
    final id = extractVideoId(raw);
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id);
  }

  bool isAvailableForLanguage(String languageCode) {
    if (languageCode != 'en') return true;
    if (hasPlayableJapaneseVideo && !hasEnglishVideoURL) return false;
    return true;
  }
}

class TheorySubcategory {
  final String name;
  final List<TheoryTopic> topics;

  TheorySubcategory({required this.name, required this.topics});
}


class FormulaEntry {
  final String latex; // 数式部分（Math.texで表示）
  final Video relatedVideo;
  final String categoryName;

  FormulaEntry({
    required this.latex,
    required this.relatedVideo,
    required this.categoryName,
  });
}
class Subcategory {
  final String name;
  final List<Video> videos;
  Subcategory({required this.name, required this.videos});
}

class Category {
  final String name;
  final String gifUrl;
  final List<Subcategory> subcategories;
  Category({required this.name, required this.gifUrl, required this.subcategories});

  String? getMindMapAsset({String languageCode = 'ja'}) =>
      Category.getMindMapAssetByName(name, languageCode: languageCode);

  String getMindMapLabel() => Category.getMindMapLabelByName(name);

  /// 単元 home 上部の全体像。`en` は orig_en の英語版、それ以外は日本語版。
  static String? getMindMapAssetByName(
    String name, {
    String languageCode = 'ja',
  }) {
    final stem = _mindMapStem(name);
    if (stem == null) return null;
    final dir = languageCode == 'en' ? 'assets/mindMap/en' : 'assets/mindMap';
    return '$dir/$stem.jpeg';
  }

  static String? _mindMapStem(String name) {
    if (name == '力学' || name == '力学理論') return 'dynamicsLandScope';
    if (name == '電磁気学' || name == '電磁気学理論') return 'emTheoryLandScope';
    if (name == '熱力学' || name == '熱力学理論') return 'thermoDynamicsLandScope';
    if (name == '波動') return 'waveLandScope';
    return null;
  }

  static String getMindMapLabelByName(String name) {
    if (name == '力学' || name == '力学理論') return '力学全体像';
    if (name == '電磁気学' || name == '電磁気学理論') return '電磁気学全体像';
    if (name == '熱力学' || name == '熱力学理論') return '熱力学全体像';
    if (name == '波動') return '波動全体像';
    return '';
  }
}

/// YouTube URLから動画IDを抽出する共通関数
String extractVideoId(String videoUrl) {
  if (videoUrl.isEmpty) return '';
  
  // 既に動画IDのみの場合（短い文字列で特殊文字が含まれていない）
  if (!videoUrl.contains('http') && !videoUrl.contains('/') && !videoUrl.contains('?')) {
    return videoUrl;
  }
  
  // youtube.com/watch?v= / youtu.be / shorts 形式
  final watchMatch = RegExp(
          r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/shorts/)([a-zA-Z0-9_-]{11})')
      .firstMatch(videoUrl);
  if (watchMatch != null) {
    return watchMatch.group(1)!;
  }
  
  // embed形式から抽出
  final embedMatch = RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})').firstMatch(videoUrl);
  if (embedMatch != null) {
    return embedMatch.group(1)!;
  }
  
  // それでも見つからない場合は、末尾の11文字を試す（動画IDは通常11文字）
  if (videoUrl.length >= 11) {
    final last11 = videoUrl.substring(videoUrl.length - 11);
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(last11)) {
      return last11;
    }
  }
  
  return videoUrl; // フォールバック: 元の文字列を返す
}


// Product class の例（既存の定義にフィールドを追加）
class Product {
  final String title;
  final String url;
  final String? imageUrl;
  final String? price;
  final int rating;
  final List<dynamic> videos;
  final String? description; // ← 商品説明を追加
  final String? imageAttribution;
  final String? imageSourceUrl;
  final String? category;

  Product({
    required this.title,
    required this.url,
    this.imageUrl,
    this.price,
    this.rating = 0,
    this.videos = const [],
    this.description,
    this.imageAttribution,
    this.imageSourceUrl,
    this.category
  });

  // Optional: Map から作るヘルパー（既存のデータから移行する際に便利）
  factory Product.fromMap(Map<String, dynamic> m) {
    final videosRaw = m['videos'];
    List<Video> vs = <Video>[];
    if (videosRaw is List<Video>) {
      vs = videosRaw;
    } else if (videosRaw is List) {
      // defensive: try to cast elements
      try {
        vs = videosRaw.cast<Video>();
      } catch (_) {
        vs = <Video>[];
      }
    }
    return Product(
      title: m['title']?.toString() ?? '',
      url: m['url']?.toString() ?? '',
      imageUrl: m['imageUrl'] as String?,
      price: m['price'] as String?,
      rating: (m['rating'] is int) ? m['rating'] as int : int.tryParse('${m['rating'] ?? 0}') ?? 0,
      videos: vs,
    );
  }

  Product copyWith({
    String? title,
    String? url,
    String? imageUrl,
    String? price,
    int? rating,
    List<Video>? videos,
  }) {
    return Product(
      title: title ?? this.title,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      videos: videos ?? this.videos,
    );
  }
}