import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/ExperimentView.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/sensorArticlesData.dart';
import 'package:joyphysics/search/searchable_articles.dart';
import 'package:joyphysics/shared_components.dart';

const String kArticleSearchHeroTag = 'home-article-search';

Widget _searchBarShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final fromHero = fromHeroContext.widget as Hero;
  return Material(color: Colors.transparent, child: fromHero.child);
}

void openArticleSearch(BuildContext context) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const ArticleSearchPage(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
    ),
  );
}

class HomeArticleSearchBox extends StatelessWidget {
  const HomeArticleSearchBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 56),
      child: Hero(
        tag: kArticleSearchHeroTag,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => openArticleSearch(context),
            borderRadius: BorderRadius.circular(24),
            child: const ArticleSearchFieldShell(
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.black54),
                  SizedBox(width: 8),
                  Text(
                    'キーワード検索',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ArticleSearchFieldShell extends StatelessWidget {
  final Widget child;

  const ArticleSearchFieldShell({Key? key, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
      child: child,
    );
  }
}

class ArticleSearchPage extends StatefulWidget {
  const ArticleSearchPage({Key? key}) : super(key: key);

  @override
  State<ArticleSearchPage> createState() => _ArticleSearchPageState();
}

class _ArticleSearchPageState extends State<ArticleSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final List<SearchableArticle> _allArticles;
  List<SearchableArticle> _results = const [];

  @override
  void initState() {
    super.initState();
    _allArticles = flattenAllSearchableArticles(
      categoriesData,
      sensorArticlesByCategory,
      sensorCategoryName: kSensorCategoryName,
    );
    _controller.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    setState(() {
      _results = filterArticlesByTitle(_allArticles, _controller.text);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('記事を検索'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Hero(
                  tag: kArticleSearchHeroTag,
                  flightShuttleBuilder: _searchBarShuttle,
                  child: const Material(
                    color: Colors.transparent,
                    child: ArticleSearchFieldShell(
                      child: SizedBox(width: double.infinity),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'キーワード検索',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      if (query.isNotEmpty)
                        GestureDetector(
                          onTap: _controller.clear,
                          child: const Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildResults(query)),
        ],
      ),
    );
  }

  Widget _buildResults(String query) {
    if (query.isEmpty) {
      return const SizedBox.expand();
    }
    if (_results.isEmpty) {
      return const Center(
        child: Text(
          '該当する記事がありません',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }
    final groups = groupArticlesByCategory(_results);
    return CustomScrollView(
      slivers: [
        for (final group in groups) ...[
          SliverToBoxAdapter(child: _CategoryBand(name: group.categoryName)),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _SearchArticleTile(
                  article: group.articles[index],
                  isLast: index == group.articles.length - 1,
                ),
                childCount: group.articles.length,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

class _CategoryBand extends StatelessWidget {
  final String name;

  const _CategoryBand({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFC3734F),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        name,
        style: const TextStyle(
          fontFamily: 'KeiFont',
          fontSize: 18,
          fontWeight: FontWeight.w300,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SearchArticleTile extends StatelessWidget {
  final SearchableArticle article;
  final bool isLast;

  const _SearchArticleTile({required this.article, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final video = article.video;
    final hasIcon = video.iconName.trim().isNotEmpty;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16 / 3),
          leading: hasIcon
              ? FutureBuilder<String>(
                  future: resolveAssetPath(video.category, video.iconName),
                  builder: (context, snapshot) {
                    Widget image = const SizedBox(width: 48, height: 27);
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      image = Image.asset(
                        snapshot.data!,
                        width: 48,
                        height: 27,
                        fit: BoxFit.contain,
                      );
                    }
                    return image;
                  },
                )
              : const SizedBox(width: 48, height: 27),
          title: TitleWithPhysicsBadge(
            title: video.title,
            badge: PhysicsBadge(
              isNew: video.isNew ?? false,
              isSimulation: video.isSimulation ?? false,
              isExperiment: video.isExperiment ?? false,
              isSmartPhoneOnly: video.isSmartPhoneOnly ?? false,
            ),
          ),
          onTap: () {
            openVideoDetail(context, video);
          },
        ),
        if (!isLast)
          Divider(
            thickness: 1.0,
            height: 0,
            indent: 16 / 3,
            endIndent: 16 / 3,
            color: Colors.grey[300],
          ),
      ],
    );
  }
}
