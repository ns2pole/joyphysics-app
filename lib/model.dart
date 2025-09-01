import 'package:flutter/material.dart';

// データモデル
class Video {
  final bool? isNew;
  final String category;
  final String iconName;
  final String title;
  final String videoURL;
  final List<String> equipment;
  final String costRating;
  final bool? isSmartPhoneOnly;
  final String? latex;
  final List<Widget>? experimentWidgets; // 複数のWidgetを許可

  Video({
    this.isNew,
    required this.category,
    required this.iconName,
    required this.title,
    required this.videoURL,
    required this.equipment,
    required this.costRating,
    this.isSmartPhoneOnly,
    this.latex,
    this.experimentWidgets, // ← optional, default null
  });

  String get assetPath => 'assets/$category/$iconName.png';

  Image getImage() => Image.asset(assetPath);
}


class TheoryTopic {
  final String title;
  final String latexContent;
  final bool isNew;

  TheoryTopic({
    required this.title,
    required this.latexContent,
    this.isNew = false,
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


