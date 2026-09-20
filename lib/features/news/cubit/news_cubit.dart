import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khabark/core/api_data_source/models/article_model.dart';
import 'package:khabark/features/news/data/news_failure.dart';
import 'package:khabark/features/news/data/news_repository.dart';

part 'news_state.dart';

const Duration searchDebounce = Duration(milliseconds: 500);
const int minSearchLength = 2;

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository _repository;

  Timer? _searchTimer;

  int _generation = 0;

  NewsCubit(this._repository) : super(const NewsInitial());

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }


  Future<void> started() async {
    final gen = ++_generation;
    emit(NewsLoading(
      category: state.category,
      query: state.query,
      articles: const <Article>[],
      page: 0,
      hasReachedMax: false,
    ));
    await _load(
      category: state.category,
      query: state.query,
      page: 1,
      append: false,
      generation: gen,
    );
  }

  Future<void> categoryChanged(String category) async {
    if (category == state.category) return;

    final gen = ++_generation;
    emit(NewsLoading(
      category: category,
      query: state.query,
      articles: const <Article>[],
      page: 0,
      hasReachedMax: false,
    ));
    await _load(
      category: category,
      query: state.query,
      page: 1,
      append: false,
      generation: gen,
    );
  }

  void searchChanged(String query) {
    final trimmed = query.trim();
    if (trimmed == state.query) return;
    if (trimmed.isNotEmpty && trimmed.length < minSearchLength) return;
    _searchTimer?.cancel();
    _searchTimer = Timer(searchDebounce, () => _runSearch(trimmed));
  }

  Future<void> refreshed() async {
    final gen = ++_generation;
    emit(NewsLoading(
      category: state.category,
      query: state.query,
      articles: state.articles,
      page: state.page,
      hasReachedMax: state.hasReachedMax,
    ));
    await _load(
      category: state.category,
      query: state.query,
      page: 1,
      append: false,
      generation: gen,
    );
  }

  Future<void> nextPageRequested() async {
    if (state.hasReachedMax) return;
    if (state is NewsLoading || state is NewsLoadingMore) return;
    if (state.articles.isEmpty) return;

    emit(NewsLoadingMore(
      category: state.category,
      query: state.query,
      articles: state.articles,
      page: state.page,
      hasReachedMax: state.hasReachedMax,
    ));
    await _load(
      category: state.category,
      query: state.query,
      page: state.page + 1,
      append: true,
      generation: _generation,
    );
  }


  Future<void> _runSearch(String trimmed) async {
    if (isClosed) return;

    final gen = ++_generation;
    emit(NewsLoading(
      category: state.category,
      query: trimmed,
      articles: const <Article>[],
      page: 0,
      hasReachedMax: false,
    ));
    await _load(
      category: state.category,
      query: trimmed,
      page: 1,
      append: false,
      generation: gen,
    );
  }

  Future<void> _load({
    required String category,
    required String query,
    required int page,
    required bool append,
    required int generation,
  }) async {
    try {
      final result = await _repository.getTopHeadlines(
        category: category,
        query: query,
        page: page,
      );

      if (!_isCurrent(generation, category, query, append)) return;

      final List<Article> merged = append
          ? _mergeDeduped(state.articles, result.articles)
          : result.articles;

      emit(NewsLoaded(
        category: category,
        query: query,
        articles: merged,
        page: page,
        hasReachedMax: result.hasReachedMax,
      ));
    } on NewsFailure catch (e) {
      if (!_isCurrent(generation, category, query, append)) return;
      _emitError(e.message);
    } catch (_) {
      if (!_isCurrent(generation, category, query, append)) return;
      _emitError('Something went wrong. Please try again.');
    }
  }

  bool _isCurrent(
    int generation,
    String category,
    String query,
    bool append,
  ) {
    if (isClosed) return false;
    if (_generation != generation) return false;
    if (state.category != category || state.query != query) return false;
    if (append && state is! NewsLoadingMore) return false;
    return true;
  }

  void _emitError(String message) {
    emit(NewsError(
      message: message,
      category: state.category,
      query: state.query,
      articles: state.articles,
      page: state.page,
      hasReachedMax: state.hasReachedMax,
    ));
  }

  List<Article> _mergeDeduped(List<Article> current, List<Article> incoming) {
    final seen = <String>{for (final a in current) a.url.trim()};
    final out = <Article>[...current];
    for (final a in incoming) {
      if (seen.add(a.url.trim())) out.add(a);
    }
    return out;
  }
}