# 🎯 Présentation de l'application **Fast2News**
<img src=docs/asset/fast2news.png>

**Fast2News** est une application mobile innovante permettant de consulter des articles d'actualité en temps réel depuis diverses sources. Développée avec Flutter, elle offre une expérience utilisateur fluide et intuitive.

---

## 🛠️ Fonctionnalités clés

- **Actualités en temps réel** : Mise à jour automatique des articles
- **Navigation optimisée** : Parcours des articles par glissement vertical
- **Recherche avancée** : Filtrage intelligent par mots-clés
- **Personnalisation** : Système de likes et favoris
- **Lecture intégrée** : Affichage des articles dans leur format d'origine
- **Mode hors-ligne** : Accès aux favoris sans connexion

---

## 💡 Expérience utilisateur

- Interface moderne avec thème sombre
- Gestes intuitifs (double-tap pour ouvrir)
- Accès rapide aux fonctionnalités
- Affichage optimisé pour la lecture

---

## 📦 Architecture technique

### Frontend Mobile
- **Framework** : Flutter (Dart)
- **Gestion d'état** : Provider
- **Stockage local** : Hive (base NoSQL légère)
- **WebView** : flutter_inappwebview

### Backend
- **Framework API** : FastAPI
- **Scraping** : BeautifulSoup/Requests
- **Format d'échange** : JSON
- **Hébergement** : Serveur dédié

---

## 🔍 Système de collecte d'articles

### Sources supportées
1. **France Info Ultramarine**
   - Portails régionaux
   - Métadonnées complètes (auteur, date, extrait)
   - Images haute résolution

2. **RCI.fm**
   - Actualités caribéennes
   - Contenu enrichi
   - Mise à jour fréquente

### Processus de scraping
- Identification des éléments HTML cibles
- Nettoyage et normalisation du contenu
- Vérification de l'intégrité des données
- Stockage temporaire en mémoire

---

## 🚀 Points forts techniques

1. **Performance** :
   - Chargement asynchrone
   - Cache intelligent
   - Optimisation des requêtes

2. **Fiabilité** :
   - Gestion des erreurs
   - Re-try automatique
   - Contrôle qualité des données

3. **Évolutivité** :
   - Architecture modulaire
   - Facilité d'ajout de nouvelles sources
   - Configuration externalisée

---

## 🔐 Sécurité & Vie privée

- Aucune collecte de données personnelles
- Chiffrement des favoris locaux
- Validation des URLs
- Protection contre les injections

---
# 🧱 Structure du backend FastAPI

Le backend se compose :

- de deux dictionnaires d’URL (France Info & RCI)
- de fonctions de scraping dédiées à chaque source
- d’une API FastAPI pour exposer les données
- d’une option de sauvegarde des articles scrappés en fichier JSON

---
# Analyse de la partie scraping


<h1>📄 Explication détaillée du scraper FastAPI + BeautifulSoup</h1>

<p>Ce projet est une API FastAPI qui scrape automatiquement des articles depuis <strong>France Info (la1ere.francetvinfo.fr)</strong> et <strong>RCI.fm</strong>, puis les expose via des routes API.</p>

<h2>📦 Imports</h2>
<pre><code>from fastapi import FastAPI
import json
import requests
from bs4 import BeautifulSoup
from starlette.responses import JSONResponse</code></pre>
<ul>
  <li><code>FastAPI</code> : framework pour créer une API web.</li>
  <li><code>json</code> : pour manipuler les données JSON.</li>
  <li><code>requests</code> : envoie les requêtes HTTP.</li>
  <li><code>BeautifulSoup</code> : analyse le HTML.</li>
  <li><code>JSONResponse</code> : permet d’envoyer des réponses JSON formatées avec UTF-8.</li>
</ul>

<h2>🌍 Dictionnaires de sources</h2>
<pre><code>dictionary_franceinfo = {
    "mq1ere": "https://la1ere.francetvinfo.fr/martinique",
    ...
}
dictionary_rci = {
    "rcimq": "https://rci.fm/martinique/infos/toutes-les-infos",
    ...
}</code></pre>

<p>Ils contiennent les URLs de chaque région à scraper.</p>

<h2>🗃️ Base de données temporaire</h2>
<pre><code>articles_db = []
HEADERS = {
    "User-Agent": "Mozilla/5.0 ..."
}</code></pre>
<ul>
  <li><code>articles_db</code> : liste globale qui stocke tous les articles scrappés.</li>
  <li><code>HEADERS</code> : imitation d’un vrai navigateur pour éviter les blocages anti-bot.</li>
</ul>

<h2>🔍 Scraping d’un article France Info</h2>
<pre><code>def fetch_article_info_franceinfo(article_url: str):</code></pre>
<ul>
  <li>Envoie une requête à l’URL d’un article.</li>
  <li>Récupère : titre, auteur, date, extrait, image.</li>
  <li>Si tout est présent, ajoute à <code>articles_db</code>.</li>
</ul>

<h2>🔁 Scraping des pages France Info</h2>
<pre><code>def fetch_all_articles_franceinfo():</code></pre>
<p>Parcourt chaque région dans <code>dictionary_franceinfo</code>. Pour chaque article, appelle <code>fetch_article_info_franceinfo</code>.</p>

<h2>📡 Scraping des articles RCI.fm</h2>
<pre><code>def fetch_articles_rci(URL):</code></pre>
<ul>
  <li>Récupère : titre, date, extrait, lien, image.</li>
  <li>L’auteur est fixé à <code>"RCI.fm"</code>.</li>
  <li>Ajoute les articles complets à <code>articles_db</code>.</li>
</ul>

<h2>🔁 Scraping de tous les RCI.fm</h2>
<pre><code>def fetch_all_articles_rci():
    for url in dictionary_rci.values():
        fetch_articles_rci(url)</code></pre>

<h2>🧠 Fusion des articles</h2>
<pre><code>def merge_articles():
    return articles_db</code></pre>

<h2>🚀 Initialisation FastAPI</h2>
<pre><code>app = FastAPI()
fetch_all_articles_franceinfo()
fetch_all_articles_rci()</code></pre>

<h2>🔌 Routes de l'API</h2>

<h3>Accueil</h3>
<pre><code>@app.get("/")
def home():
    return {"message": "Bienvenue sur l'API de scraping d'articles !"}</code></pre>

<h3>Obtenir les articles</h3>
<pre><code>@app.get("/articles")
def get_articles():
    return JSONResponse(...)</code></pre>

<h3>Sauvegarder en JSON</h3>
<pre><code>@app.get("/save_articles_to_json")
def save_articles_to_json():
    with open("articles.json", "w", encoding="utf-8") as f:
        json.dump(...)
    return {"message": "Les articles ont été sauvegardés"}</code></pre>

<h2>🧩 Résumé du flux</h2>
<ol>
  <li>Au lancement du script : exécution des scrapers.</li>
  <li>Les articles sont stockés dans <code>articles_db</code>.</li>
  <li>API disponible via :
    <ul>
      <li><code>/</code> : accueil</li>
      <li><code>/articles</code> : liste des articles</li>
      <li><code>/save_articles_to_json</code> : sauvegarde dans <code>articles.json</code></li>
    </ul>
  </li>
</ol>articles dans un fichier local articles.json (UTF-8, indenté).

<h2>🖥️ Hébergement et exécution du code</h2>
<p>
  Ce script est conçu pour être <strong>exécuté sur un serveur</strong>, car il comprend :
</p>
<ul>
  <li>Une <strong>API FastAPI</strong> avec plusieurs routes web (<code>/</code>, <code>/articles</code>, <code>/save_articles_to_json</code>).</li>
  <li>Un <strong>scraping automatique</strong> de sites d’actualités (France Info et RCI.fm) déclenché au démarrage.</li>
  <li>Une <strong>base d’articles en mémoire</strong> (<code>articles_db</code>) remplie automatiquement.</li>
  <li>La possibilité de <strong>sauvegarder les articles</strong> dans un fichier JSON local (<code>articles.json</code>).</li>
</ul>
<p>
  Dans notre cas, l’application est <strong>hébergée sur <a href="https://render.com" target="_blank">Render</a></strong>, un service cloud qui permet :
</p>
<ul>
  <li>De lancer automatiquement le scraping à chaque démarrage du serveur.</li>
  <li>De rendre l’API accessible publiquement via une URL Render.</li>
  <li>De recevoir des requêtes HTTP et retourner les données collectées.</li>
</ul>
<p>
  💡 <strong>Remarque :</strong> Pour rendre le fichier <code>articles.json</code> téléchargeable, on peut soit l’exposer via une route FastAPI, soit l’envoyer vers un service de stockage externe (comme Amazon S3).
</p>
<p>
  💡 Pour lancer localement : <code>uvicorn main:app --reload</code><br>
  💡 Pour déployer : connecter le dépôt Git à Render et utiliser <code>uvicorn main:app --host 0.0.0.0 --port 10000</code> comme commande de démarrage.
</p>

# 🧱 Partie FrontEnd 

  <h1>🔍 Analyse du Code Flutter - Fast2News</h1>

  <h2>1. Initialisation de Hive</h2>
  <pre><code>void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ArticleAdapter());
  await Hive.openBox&lt;Article&gt;('favorites');

  runApp(MyApp());
}</code></pre>
  <div class="note">
    ✅ Bon usage de <code>WidgetsFlutterBinding.ensureInitialized()</code> avant de faire des appels asynchrones. Hive est bien initialisé et prêt à sauvegarder les favoris.
  </div>

  <h2>2. Chargement et gestion des favoris</h2>
  <pre><code>void _toggleFavorite(Article article) {
  setState(() {
    if (favoriteArticles.contains(article)) {
      favoriteArticles.remove(article);
      favoritesBox.delete(article.titre);
    } else {
      favoriteArticles.add(article);
      favoritesBox.put(article.titre, article);
    }
  });
}</code></pre>
  <div class="warning">
    ⚠️ <strong>Attention :</strong> <code>contains(article)</code> utilise l’opérateur <code>==</code>. S’il n’est pas redéfini dans le modèle <code>Article</code>, cela peut ne pas fonctionner correctement.
  </div>

  <h2>3. Affichage des articles - <code>PageView</code></h2>
  <pre><code>PageView.builder(
  scrollDirection: Axis.vertical,
  itemCount: articles.length,
  itemBuilder: (context, index) {
    Article article = articles[index];
    return GestureDetector(
      onDoubleTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =&gt; WebViewPage(url: article.lien),
          ),
        );
      },
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            Image.network(article.image),
            Text(article.titre),
            Text(article.extrait),
            // ...
          ],
        ),
      ),
    );
  },
)</code></pre>
  <div class="note">
    ✅ Bonne utilisation de <code>PageView</code> pour un scroll vertical et de <code>GestureDetector</code> pour un double tap menant à la WebView.
  </div>

  <h2>4. Boutons Like et Favori</h2>
  <pre><code>IconButton(
  icon: Icon(
    likedArticles.contains(article)
      ? Icons.favorite
      : Icons.favorite_border,
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
)</code></pre>
  <div class="warning">
    ⚠️ Les likes ne sont pas sauvegardés localement. En quittant l’app, la liste est perdue.
  </div>

  <h2>5. Page des Favoris</h2>
  <pre><code>FavoritesPage({
  required this.likedArticles,
  required this.favoriteArticles,
})</code></pre>
  <div class="note">
    ✅ La séparation entre articles likés et favoris est claire. Les articles sont réaffichés dans une <code>ListView</code>, avec navigation vers la WebView.
  </div>

  <h2>6. WebView - Lecture des articles</h2>
  <pre><code>class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({ required this.url });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Article')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}</code></pre>
  <div class="note">
    ✅ Lecture propre via <code>flutter_inappwebview</code>, bonne encapsulation.
  </div>

  <h2>7. Recherche d’articles</h2>
  <pre><code>showSearch(
  context: context,
  delegate: ArticleSearchDelegate(
    articles,
    onTap: (article) {
      Navigator.push(...);
    },
  ),
);</code></pre>
  <div class="note">
    ✅ Intégration efficace de la recherche avec <code>SearchDelegate</code>. Permet un accès rapide à l’article désiré.
  </div>

