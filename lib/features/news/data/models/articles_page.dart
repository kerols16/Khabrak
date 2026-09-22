import 'package:equatable/equatable.dart';

import '../../../../core/api_data_source/models/article_model.dart';

class ArticlesPage extends Equatable {
  final List<Article> articles;
  final bool hasReachedMax;

  const ArticlesPage({required this.articles, required this.hasReachedMax});

  @override
  List<Object?> get props => [articles, hasReachedMax];
}
