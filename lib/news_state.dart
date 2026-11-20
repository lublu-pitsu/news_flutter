import 'package:flutter/material.dart';
import 'article.dart';
import 'news_api_client.dart';
import 'news_repository.dart';

enum Status { loading, success, error }

class NewsState extends ChangeNotifier {
  static const int pageSize = 10;

  final repo = NewsRepository();

  Status status = Status.loading;
  String? error;
  List<Article> articles = [];

  String query = '';
  String category = 'general';
  int page = 1;
  bool loadingMore = false;
  bool hasMore = true;

  Future<void> load() async {
    status = Status.loading;
    error = null;
    notifyListeners();
    await fetch();
  }

  Future<void> refresh() async {
    await fetch();
  }

  Future<void> fetch() async {
    try {
      final list = await repo.getArticles(
        page: 1,
        limit: pageSize,
        search: query,
        category: category,
      );
      page = 1;
      articles = list;
      hasMore = list.length == pageSize;
      status = Status.success;
    } on NewsException catch (e) {
      error = e.message;
      status = Status.error;
    } catch (_) {
      error = 'Неизвестная ошибка';
      status = Status.error;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (loadingMore || !hasMore || status != Status.success) return;

    loadingMore = true;
    notifyListeners();

    try {
      final list = await repo.getArticles(
        page: page + 1,
        limit: pageSize,
        search: query,
        category: category,
      );
      page++;
      articles = [...articles, ...list];
      hasMore = list.length == pageSize;
    } catch (_) {
      hasMore = false;
    }
    loadingMore = false;
    notifyListeners();
  }

  void setQuery(String text) {
    query = text;
    category = 'general';
    load();
  }

  void setCategory(String value) {
    category = value;
    query = '';
    load();
  }
}
