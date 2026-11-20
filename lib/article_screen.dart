import 'package:flutter/material.dart';
import 'article.dart';

class ArticleScreen extends StatelessWidget {
  final Article article;

  const ArticleScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final d = article.date;
    final date = '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Статья'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                article.image,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    height: 220,
                    color: Colors.grey.shade300,
                    child: Icon(Icons.image_not_supported, size: 48),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              '$date • ${article.source}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(article.summary),
            SizedBox(height: 24),
            Text(
              'Источник:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SelectableText(
              article.url,
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
