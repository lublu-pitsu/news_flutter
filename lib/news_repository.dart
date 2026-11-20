import 'article.dart';
import 'news_api_client.dart';

class NewsRepository {
  final NewsApiClient api;

  NewsRepository({NewsApiClient? api}) : api = api ?? NewsApiClient();

  Future<List<Article>> getArticles({
    required int page,
    required int limit,
    String search = '',
    String category = 'general',
  }) {
    return api.loadArticles(
      page: page,
      limit: limit,
      search: search.trim(),
      category: category,
    );
  }
}
