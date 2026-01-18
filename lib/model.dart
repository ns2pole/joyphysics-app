import 'package:flutter/material.dart';

// データモデル
class Video {
  final bool? isNew;
  final bool? inPreparation;
  final String category;
  final String iconName;
  final String title;
  final String videoURL;
  final List<String> equipment;
  final String costRating;
  final bool? isSmartPhoneOnly;
  final bool? isSimulation; // シミュレーション・アニメーションかどうか
  final bool? isExperiment; // 実験かどうか
  final String? latex;
  final List<Widget>? experimentWidgets; // 複数のWidgetを許可

  Video({
    this.isNew,
    this.inPreparation = false,
    required this.category,
    required this.iconName,
    required this.title,
    required this.videoURL,
    required this.equipment,
    required     this.costRating,
    this.isSmartPhoneOnly,
    this.isSimulation,
    this.isExperiment,
    this.latex,
    this.experimentWidgets, // ← optional, default null
  });

  String get assetPath => 'assets/$category/$iconName.png';

  Image getImage() => Image.asset(assetPath);
}

class TheoryTopic {
  final String title;
  final String latexContent;
  final String? videoURL;
  final bool? inPreparation;
  final bool isNew;
  final String? imageAsset; // ここを追加

  TheoryTopic({
    required this.title,
    required this.latexContent,
    this.videoURL,
    this.isNew = false,
    this.inPreparation = false,
    this.imageAsset, // コンストラクタにも追加
  });
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