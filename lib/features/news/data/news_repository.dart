import 'package:dio/dio.dart';

import '../../../core/api_data_source/models/article_model.dart';
import '../../../core/api_data_source/models/news_response_model.dart';
import '../../../core/api_data_source/news_api_service.dart';
import 'models/articles_page.dart';
import 'news_failure.dart';

class NewsRepository {
  final NewsApiService _service;
  static const int pageSize = 20;
  static const String _country = 'us';
  static const int _maxResultsFreePlan = 100;
  static const List<String> _consentFragments = [
    'consent.yahoo.com',
    'collectConsent',
    'zustimmung',
    '/consent',
  ];
  NewsRepository(this._service);

  Future<ArticlesPage> getTopHeadlines({
    required String category,
    String query = '',
    required int page,
  }) async {
    final trimmedQuery = query.trim();

    NewsResponse response;
    try {
      response = await _service.getTopHeadlines(
        country: _country,
        category: category,
        q: trimmedQuery.isEmpty ? null : trimmedQuery,
        pageSize: pageSize,
        page: page,
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map && body['code'] == 'maximumResultsReached') {
        return const ArticlesPage(articles: [], hasReachedMax: true);
      }
      throw NewsFailure(_messageForDio(e));
    } catch (_) {
      throw const NewsFailure('Something went wrong. Please try again.');
    }

    if (response.status != 'ok') {
      throw NewsFailure('NewsAPI returned status "${response.status}".');
    }

    final cleaned = _cleanArticles(response.articles);

    final cap = response.totalResults < _maxResultsFreePlan
        ? response.totalResults
        : _maxResultsFreePlan;
    final hasReachedMax = response.articles.isEmpty || page * pageSize >= cap;

    return ArticlesPage(articles: cleaned, hasReachedMax: hasReachedMax);
  }

  List<Article> _cleanArticles(List<Article> input) {
    final seenUrls = <String>{};
    final out = <Article>[];

    for (final article in input) {
      final title = article.title.trim();
      if (title.isEmpty || title == '[Removed]') continue;

      final url = article.url.trim();
      if (url.isEmpty) continue;
      if (_consentFragments.any((fragment) => url.contains(fragment))) continue;

      if (article.publishedAt == null) continue;

      final description = article.description.trim();
      final image = article.urlToImage?.trim() ?? '';
      if (description.isEmpty && image.isEmpty) continue;

      if (!seenUrls.add(url)) continue;

      out.add(_stripPublisherSuffix(article));
    }

    return out;
  }

  Article _stripPublisherSuffix(Article article) {
    final name = article.source.name.trim();
    if (name.isEmpty) return article;

    final suffix = ' - $name';
    final title = article.title;
    if (title.length < suffix.length) return article;

    final tail = title.substring(title.length - suffix.length);
    if (tail.toLowerCase() != suffix.toLowerCase()) return article;

    final stripped = title.substring(0, title.length - suffix.length).trim();
    if (stripped.isEmpty) return article;

    return article.copyWith(title: stripped);
  }

  String _messageForDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'No internet connection. Check your network and try again.';
      default:
        break;
    }

    final status = e.response?.statusCode;
    if (status == 401) {
      return 'Invalid API key. Check your env.json configuration.';
    }
    if (status == 429) {
      return 'Too many requests. Please try again later.';
    }

    final body = e.response?.data;
    if (body is Map) {
      final message = body['message'];
      if (message is String && message.isNotEmpty) return message;
    }

    return 'Something went wrong. Please try again.';
  }
}
