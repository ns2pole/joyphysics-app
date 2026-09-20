import 'package:joyphysics/model.dart';

class SearchableArticle {
  final Video video;
  final String categoryName;
  final List<String> keywords;

  const SearchableArticle({
    required this.video,
    required this.categoryName,
    this.keywords = const [],
  });
}

bool isSearchableVideo(Video video) {
  if (video.inPreparation == true) return false;
  final hasVideo = video.videoURL.isNotEmpty &&
      video.videoURL.trim() != '（動画URLをここに）' &&
      !video.videoURL.contains('（動画URL');
  final hasWidget = video.experimentWidgets != null &&
      video.experimentWidgets!.isNotEmpty;
  return hasVideo || hasWidget;
}

List<SearchableArticle> flattenSearchableArticles(List<Category> categories) {
  final seen = <Video>{};
  final articles = <SearchableArticle>[];
  for (final category in categories) {
    for (final subcategory in category.subcategories) {
      for (final video in subcategory.videos) {
        if (!isSearchableVideo(video)) continue;
        if (!seen.add(video)) continue;
        articles.add(SearchableArticle(
          video: video,
          categoryName: category.name,
        ));
      }
    }
  }
  return articles;
}

List<SearchableArticle> flattenAllSearchableArticles(
  List<Category> categories,
  Map<String, List<Video>> sensorArticlesByCategory, {
  String sensorCategoryName = 'センサー',
}) {
  final articles = flattenSearchableArticles(categories);
  final seen = articles.map((article) => article.video).toSet();
  for (final entry in sensorArticlesByCategory.entries) {
    for (final video in entry.value) {
      if (!isSearchableVideo(video)) continue;
      if (!seen.add(video)) continue;
      articles.add(SearchableArticle(
        video: video,
        categoryName: sensorCategoryName,
        keywords: [entry.key],
      ));
    }
  }
  return articles;
}

bool articleMatchesQuery(SearchableArticle article, String normalized) {
  if (article.video.title.toLowerCase().contains(normalized)) return true;
  if (article.categoryName.toLowerCase().contains(normalized)) return true;
  for (final keyword in article.keywords) {
    if (keyword.toLowerCase().contains(normalized)) return true;
  }
  return false;
}

List<SearchableArticle> filterArticlesByTitle(
  List<SearchableArticle> articles,
  String query,
) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return const [];
  return articles
      .where((article) => articleMatchesQuery(article, normalized))
      .toList();
}

class SearchableArticleGroup {
  final String categoryName;
  final List<SearchableArticle> articles;

  const SearchableArticleGroup({
    required this.categoryName,
    required this.articles,
  });
}

List<SearchableArticleGroup> groupArticlesByCategory(
  List<SearchableArticle> articles,
) {
  final groups = <SearchableArticleGroup>[];
  for (final article in articles) {
    if (groups.isEmpty || groups.last.categoryName != article.categoryName) {
      groups.add(SearchableArticleGroup(
        categoryName: article.categoryName,
        articles: [article],
      ));
    } else {
      groups.last.articles.add(article);
    }
  }
  return groups;
}
