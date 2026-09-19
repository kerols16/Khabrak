
import 'package:khabark/core/api_data_source/models/article_model.dart';

class NewsResponse {
  final String status;
  final int totalResults;
  final List<Article> articles;

  const NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] as String? ?? '',
      totalResults: json['totalResults'] as int? ?? 0,
      articles: (json['articles'] as List<dynamic>? ?? [])
          .map((item) => Article.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'totalResults': totalResults,
      'articles': articles.map((item) => item.toJson()).toList(),
    };
  }
}
