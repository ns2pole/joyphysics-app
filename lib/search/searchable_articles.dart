import 'package:joyphysics/model.dart';

class SearchableArticle {
  final Video video;
  final String categoryName;
  final String subcategoryName;
  final List<String> keywords;

  const SearchableArticle({
    required this.video,
    required this.categoryName,
    this.subcategoryName = '',
    this.keywords = const [],
  });
}

bool isListedArticle(Video video) {
  final hasVideo = video.videoURL.isNotEmpty &&
      video.videoURL.trim() != '（動画URLをここに）' &&
      !video.videoURL.contains('（動画URL');
  final hasWidget = video.experimentWidgets != null &&
      video.experimentWidgets!.isNotEmpty;
  return hasVideo || hasWidget;
}

bool isSearchableVideo(Video video, {String languageCode = 'ja'}) {
  if (video.inPreparation == true) return false;
  if (!isListedArticle(video)) return false;
  return video.isAvailableForLanguage(languageCode);
}

/// ホームのカテゴリ名横に出す記事数。準備中は含めない。
int countCategoryArticles(Category category, {String languageCode = 'ja'}) {
  final seen = <Video>{};
  var count = 0;
  for (final subcategory in category.subcategories) {
    for (final video in subcategory.videos) {
      if (!isSearchableVideo(video, languageCode: languageCode)) continue;
      if (!seen.add(video)) continue;
      count++;
    }
  }
  return count;
}

List<SearchableArticle> flattenSearchableArticles(
  List<Category> categories, {
  String languageCode = 'ja',
}) {
  final seen = <Video>{};
  final articles = <SearchableArticle>[];
  for (final category in categories) {
    for (final subcategory in category.subcategories) {
      for (final video in subcategory.videos) {
        if (!isSearchableVideo(video, languageCode: languageCode)) continue;
        if (!seen.add(video)) continue;
        articles.add(SearchableArticle(
          video: video,
          categoryName: category.name,
          subcategoryName: subcategory.name,
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
  String languageCode = 'ja',
}) {
  final articles = flattenSearchableArticles(
    categories,
    languageCode: languageCode,
  );
  final seen = articles.map((article) => article.video).toSet();
  for (final entry in sensorArticlesByCategory.entries) {
    for (final video in entry.value) {
      if (!isSearchableVideo(video, languageCode: languageCode)) continue;
      if (!seen.add(video)) continue;
      articles.add(SearchableArticle(
        video: video,
        categoryName: sensorCategoryName,
        subcategoryName: entry.key,
        keywords: [entry.key],
      ));
    }
  }
  return articles;
}

bool articleMatchesQuery(SearchableArticle article, String normalized) {
  if (article.video.title.toLowerCase().contains(normalized)) return true;
  final titleEn = article.video.titleEn;
  if (titleEn != null && titleEn.toLowerCase().contains(normalized)) {
    return true;
  }
  if (article.categoryName.toLowerCase().contains(normalized)) return true;
  if (article.subcategoryName.toLowerCase().contains(normalized)) return true;
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
