import 'package:flutter/material.dart';
import 'article.dart';
import 'news_state.dart';
import 'article_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final logic = NewsState();

  bool searching = false;

  final Map<String, String> categories = {
    'Все': 'general',
    'Технологии': 'technology',
    'Бизнес': 'business',
    'Спорт': 'sports',
    'Наука': 'science',
    'Здоровье': 'health',
  };

  @override
  void initState() {
    super.initState();
    logic.addListener(() {
      setState(() {});
    });
    scroll.addListener(() {
      if (scroll.position.pixels >= scroll.position.maxScrollExtent - 200) {
        logic.loadMore();
      }
    });
    logic.load();
  }

  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  String formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} мин назад';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} ч назад';
    }
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  void openArticle(Article a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleScreen(article: a),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searching
            ? TextField(
                controller: input,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (text) {
                  logic.setQuery(text);
                },
                decoration: InputDecoration(
                  hintText: 'Поиск статей...',
                  border: InputBorder.none,
                ),
              )
            : Text('Новости'),
        actions: [
          IconButton(
            icon: Icon(searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                searching = !searching;
              });
              if (!searching && logic.query.isNotEmpty) {
                input.clear();
                logic.setQuery('');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          chips(),
          Expanded(
            child: content(),
          ),
        ],
      ),
    );
  }

  Widget chips() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        children: categories.entries.map((e) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(e.key),
              selected: logic.category == e.value && logic.query.isEmpty,
              onSelected: (_) {
                input.clear();
                logic.setCategory(e.value);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget content() {
    switch (logic.status) {
      case Status.loading:
        return Center(child: CircularProgressIndicator());
      case Status.error:
        return errorView();
      case Status.success:
        if (logic.articles.isEmpty) {
          return Center(child: Text('Ничего не найдено'));
        }
        return list();
    }
  }

  Widget errorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48),
            SizedBox(height: 12),
            Text(
              logic.error ?? 'Ошибка',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: logic.load,
              icon: Icon(Icons.refresh),
              label: Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget list() {
    final items = logic.articles;

    return RefreshIndicator(
      onRefresh: logic.refresh,
      child: ListView.builder(
        controller: scroll,
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length + 1,
        itemBuilder: (context, i) {
          if (i == items.length) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: logic.loadingMore ? CircularProgressIndicator() : SizedBox(),
              ),
            );
          }
          if (i == 0) {
            return mainCard(items[i]);
          }
          return newsCard(items[i]);
        },
      ),
    );
  }

  Widget picture(String url, {double? height, double? width}) {
    return Image.network(
      url,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return Container(
          height: height,
          width: width,
          color: Colors.grey.shade300,
          child: Icon(Icons.image_not_supported),
        );
      },
    );
  }

  Widget mainCard(Article a) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          openArticle(a);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              picture(a.image, height: 220, width: double.infinity),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '${formatDate(a.date)} • ${a.source}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget newsCard(Article a) {
    return InkWell(
      onTap: () {
        openArticle(a);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: picture(a.image, height: 88, width: 88),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    a.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${formatDate(a.date)} • ${a.source}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
