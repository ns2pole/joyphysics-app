import 'package:flutter/material.dart';

// データモデル
class Video {
  final String category;
  final String iconName;
  final String title;
  final String videoURL;
  final List<String> equipment;
  final String costRating;
  final String? latex;

  Video({
    required this.category,
    required this.iconName,
    required this.title,
    required this.videoURL,
    required this.equipment,
    required this.costRating,
    this.latex,
  });

  String get assetPath => 'assets/$category/$iconName.png';

  Image getImage() => Image.asset(assetPath);
}