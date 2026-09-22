part of 'news_cubit.dart';

sealed class NewsState extends Equatable {
  final String category;
  final String query;
  final List<Article> articles;
  final int page;
  final bool hasReachedMax;

  const NewsState({
    this.category = 'general',
    this.query = '',
    this.articles = const <Article>[],
    this.page = 0,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [category, query, articles, page, hasReachedMax];
}

class NewsInitial extends NewsState {
  const NewsInitial({
    super.category,
    super.query,
    super.articles,
    super.page,
    super.hasReachedMax,
  });
}

class NewsLoading extends NewsState {
  const NewsLoading({
    super.category,
    super.query,
    super.articles,
    super.page,
    super.hasReachedMax,
  });
}

class NewsLoaded extends NewsState {
  const NewsLoaded({
    super.category,
    super.query,
    super.articles,
    super.page,
    super.hasReachedMax,
  });
}

class NewsLoadingMore extends NewsState {
  const NewsLoadingMore({
    super.category,
    super.query,
    super.articles,
    super.page,
    super.hasReachedMax,
  });
}

class NewsError extends NewsState {
  final String message;

  const NewsError({
    required this.message,
    super.category,
    super.query,
    super.articles,
    super.page,
    super.hasReachedMax,
  });

  @override
  List<Object?> get props => [
    message,
    category,
    query,
    articles,
    page,
    hasReachedMax,
  ];
}
