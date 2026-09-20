import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khabark/core/api_data_source/models/article_model.dart';
import 'package:khabark/core/constants/app_spacing.dart';
import 'package:khabark/core/theme/app_colors.dart';
import 'package:khabark/core/theme/app_text_styles.dart';
import 'package:khabark/core/widgets/category_chip.dart';
import 'package:khabark/core/widgets/empty_view.dart';
import 'package:khabark/core/widgets/error_view.dart';
import 'package:khabark/core/widgets/shimmer_box.dart';
import 'package:khabark/features/news/presentation/widgets/article_card.dart';
import 'package:khabark/features/news/presentation/widgets/featured_card.dart';

/// Primary news feed screen.
///
/// Data & callbacks are supplied by the parent (HomePage). This widget does
/// not import flutter_bloc and knows nothing about the Cubit.
class HomeScreen extends StatefulWidget {
  final List<Article> articles;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? errorMessage;
  final String selectedCategory;
  final String query;
  final String? userAvatarUrl;

  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Article> onArticleTap;
  final ValueChanged<Article> onShare;
  final VoidCallback onProfileTap;

  const HomeScreen({
    super.key,
    required this.articles,
    required this.isLoading,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.errorMessage,
    required this.selectedCategory,
    required this.query,
    this.userAvatarUrl,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onRetry,
    required this.onCategorySelected,
    required this.onSearchChanged,
    required this.onArticleTap,
    required this.onShare,
    required this.onProfileTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = [
    'general',
    'business',
    'technology',
    'sports',
    'science',
    'health',
    'entertainment',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query &&
        _searchController.text != widget.query) {
      _searchController.text = widget.query;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Guard rails: never page while loading, errored, or exhausted.
  void _onScroll() {
    if (widget.hasReachedMax) return;
    if (widget.errorMessage != null) return;
    if (widget.isLoading || widget.isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // No bottomNavigationBar here — MainShell owns the NavigationBar.
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: widget.onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.s,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Khabark',
                            style: GoogleFonts.merriweather(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: widget.onProfileTap,
                        borderRadius: BorderRadius.circular(20),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.surfaceDim,
                          backgroundImage: widget.userAvatarUrl != null
                              ? NetworkImage(widget.userAvatarUrl!)
                              : null,
                          child: widget.userAvatarUrl == null
                              ? const Icon(
                                  Icons.person,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.xs,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSpacing.inputBorderRadius,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: widget.onSearchChanged,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'Search news...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.onSearchChanged('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 44,
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.s),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category.toLowerCase() ==
                          widget.selectedCategory.toLowerCase();
                      return CategoryChip(
                        label: category[0].toUpperCase() +
                            category.substring(1),
                        isSelected: isSelected,
                        onSelected: () => widget.onCategorySelected(category),
                      );
                    },
                  ),
                ),
              ),
              if (widget.isLoading) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: const [
                        ShimmerBox(
                          width: double.infinity,
                          height: 210,
                          borderRadius: 16,
                        ),
                        SizedBox(height: AppSpacing.m),
                        ShimmerBox(
                          width: double.infinity,
                          height: 240,
                          borderRadius: 16,
                        ),
                        SizedBox(height: AppSpacing.m),
                        ShimmerBox(
                          width: double.infinity,
                          height: 240,
                          borderRadius: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (widget.errorMessage != null) ...[
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(
                    message: widget.errorMessage!,
                    onRetry: widget.onRetry,
                  ),
                ),
              ] else if (widget.articles.isEmpty) ...[
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(
                    query: widget.query,
                    onClear: () {
                      _searchController.clear();
                      widget.onSearchChanged('');
                    },
                  ),
                ),
              ] else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: FeaturedCard(
                      article: widget.articles.first,
                      onTap: () => widget.onArticleTap(widget.articles.first),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.m),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 380,
                      mainAxisSpacing: AppSpacing.m,
                      crossAxisSpacing: AppSpacing.m,
                      childAspectRatio: 0.82,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final article = widget.articles[index + 1];
                        return ArticleCard(
                          article: article,
                          onTap: () => widget.onArticleTap(article),
                          onShare: () => widget.onShare(article),
                        );
                      },
                      childCount: widget.articles.length - 1,
                    ),
                  ),
                ),
                if (widget.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.l),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.l),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}