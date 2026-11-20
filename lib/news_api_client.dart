import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'article.dart';

class NewsException implements Exception {
  final String message;

  NewsException(this.message);

  @override
  String toString() {
    return message;
  }
}

class NewsApiClient {
  static const String host = 'gnews.io';

  String get key => dotenv.env['API_KEY'] ?? '';

  Future<List<Article>> loadArticles({
    required int page,
    required int limit,
    String search = '',
    String category = 'general',
  }) async {
    final params = {
      'lang': 'ru',
      'max': '$limit',
      'page': '$page',
      'apikey': key,
    };

    String path = '/api/v4/top-headlines';
    if (search.isNotEmpty) {
      path = '/api/v4/search';
      params['q'] = search;
    } else {
      params['category'] = category;
    }

    http.Response res;
    try {
      res = await http.get(Uri.https(host, path, params)).timeout(Duration(seconds: 10));
    } catch (e) {
      throw NewsException('Нет соединения с интернетом');
    }

    if (res.statusCode == 401) {
      throw NewsException('Неверный ключ API');
    }
    if (res.statusCode == 403 || res.statusCode == 429) {
      throw NewsException('Превышен лимит запросов');
    }
    if (res.statusCode >= 500) {
      throw NewsException('Ошибка сервера (${res.statusCode})');
    }
    if (res.statusCode != 200) {
      throw NewsException('Ошибка запроса (${res.statusCode})');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = data['articles'] as List;

    return list.map((a) => parse(a as Map<String, dynamic>)).toList();
  }

  Article parse(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>?;

    return Article(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      summary: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      source: source?['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      date: DateTime.parse(json['publishedAt'] as String).toLocal(),
    );
  }
}
