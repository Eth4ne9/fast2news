import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/api_service.dart';
import 'models/article.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ArticleAdapter()); // Important si ce n’est pas déjà fait

  await Hive.openBox<Article>('favorites'); // Ouvre ta box ici avant runApp

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Articles Scrappés',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ArticlesPage(),
    );
  }
}

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  late Future<List<Article>> futureArticles;
  List<Article> likedArticles = [];
  List<Article> favoriteArticles = [];
  late Box<Article> favoritesBox;

  @override
  void initState() {
    super.initState();
    futureArticles = ApiService().fetchArticles();
    favoritesBox = Hive.box<Article>('favorites');
    _loadFavorites();
  }

  void _loadFavorites() {
    final favorites = favoritesBox.values.toList();
    setState(() {
      favoriteArticles = favorites;
    });
  }

  void _toggleFavorite(Article article) {
    setState(() {
      if (favoriteArticles.contains(article)) {
        favoriteArticles.remove(article);
        favoritesBox.delete(article.titre);
      } else {
        favoriteArticles.add(article);
        favoritesBox.put(article.titre, article);
      }
    });
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesPage(
          likedArticles: likedArticles,
          favoriteArticles: favoriteArticles,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fast2News'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              List<Article> articles = await futureArticles;
              showSearch(
                context: context,
                delegate: ArticleSearchDelegate(
                  articles,
                  onTap: (article) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebViewPage(url: article.lien),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'favoris') {
                _navigateToFavorites();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'favoris', child: Text('Articles Favoris')),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucun article disponible"));
          }

          List<Article> articles = snapshot.data!;
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: articles.length,
            itemBuilder: (context, index) {
              Article article = articles[index];

              return GestureDetector(
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewPage(url: article.lien),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.black,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      article.image.isNotEmpty
                          ? Image.network(
                        article.image,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      )
                          : SizedBox(height: 250),
                      SizedBox(height: 20),
                      Text(
                        article.titre,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        article.extrait,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.white, size: 16),
                          SizedBox(width: 5),
                          Text(
                            article.auteur,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 15),
                          Icon(Icons.calendar_today, color: Colors.white, size: 16),
                          SizedBox(width: 5),
                          Text(
                            article.date,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              likedArticles.contains(article)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: likedArticles.contains(article) ? Colors.red : Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                if (likedArticles.contains(article)) {
                                  likedArticles.remove(article);
                                } else {
                                  likedArticles.add(article);
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              favoriteArticles.contains(article)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: favoriteArticles.contains(article) ? Colors.yellow : Colors.white,
                            ),
                            onPressed: () {
                              _toggleFavorite(article);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<Article> likedArticles;
  final List<Article> favoriteArticles;

  const FavoritesPage({super.key, required this.likedArticles, required this.favoriteArticles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Articles Favoris')),
      body: ListView(
        children: [
          if (likedArticles.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("❤️ Articles Likés", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            for (var article in likedArticles)
              GestureDetector(
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewPage(url: article.lien),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(article.titre),
                  subtitle: Text(article.extrait),
                  leading: Icon(Icons.favorite, color: Colors.red),
                ),
              ),
          ],
          if (favoriteArticles.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("📌 Articles Favoris", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            for (var article in favoriteArticles)
              GestureDetector(
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewPage(url: article.lien),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(article.titre),
                  subtitle: Text(article.extrait),
                  leading: Icon(Icons.bookmark, color: Colors.yellow),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Article')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}

class ArticleSearchDelegate extends SearchDelegate {
  final List<Article> articles;
  final Function(Article) onTap;

  ArticleSearchDelegate(this.articles, {required this.onTap});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = articles.where((a) => a.titre.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(
      children: results.map((article) {
        return ListTile(
          title: Text(article.titre),
          onTap: () => onTap(article),
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = articles.where((a) => a.titre.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(
      children: suggestions.map((article) {
        return ListTile(
          title: Text(article.titre),
          onTap: () => onTap(article),
        );
      }).toList(),
    );
  }
}
