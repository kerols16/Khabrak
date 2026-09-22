import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khabark/core/api_data_source/models/article_model.dart';
import 'package:khabark/features/auth/cubit/auth_cubit.dart';
import 'package:khabark/features/news/cubit/news_cubit.dart';
import 'package:khabark/features/news/presentation/pages/article_details_page.dart';
import 'package:khabark/features/news/presentation/screens/home_screen.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onProfileTap;

  const HomePage({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final String? avatarUrl = authState is Authenticated
        ? authState.photoUrl
        : null;

    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        final cubit = context.read<NewsCubit>();

        return HomeScreen(
          articles: state.articles,
          isLoading:
              state is NewsInitial ||
              (state is NewsLoading && state.articles.isEmpty),
          isLoadingMore: state is NewsLoadingMore,
          hasReachedMax: state.hasReachedMax,
          errorMessage: state is NewsError ? state.message : null,
          selectedCategory: state.category,
          query: state.query,
          userAvatarUrl: avatarUrl,
          onRefresh: () => cubit.refreshed(),
          onLoadMore: cubit.nextPageRequested,
          onRetry: state.articles.isEmpty
              ? cubit.started
              : cubit.nextPageRequested,
          onCategorySelected: cubit.categoryChanged,
          onSearchChanged: cubit.searchChanged,
          onArticleTap: (Article article) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ArticleDetailsPage(article: article),
              ),
            );
          },
          onShare: (Article article) =>
              SharePlus.instance.share(ShareParams(text: article.url)),
          onProfileTap: onProfileTap,
        );
      },
    );
  }
}
