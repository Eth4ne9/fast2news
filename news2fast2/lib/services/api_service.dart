import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ApiService {
  static const String baseUrl = "https://scrapfwi.onrender.com"; // URL de l'API

  Future<List<Article>> fetchArticles() async {
    final response = await http.get(Uri.parse("$baseUrl/articles"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> articlesJson = jsonData['articles'];




      return articlesJson.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception("Échec de la récupération des articles");
    }
  }
}
