import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:khabark/core/api_data_source/models/article_model.dart';
import 'package:khabark/core/constants/app_spacing.dart';
import 'package:khabark/core/theme/app_colors.dart';
import 'package:khabark/core/theme/app_text_styles.dart';
import 'package:khabark/core/utils/time_ago.dart';
import 'package:khabark/core/widgets/source_placeholder.dart';
import 'package:khabark/features/news/presentation/utils/hero_tag.dart';

/// Null-safe editorial card for news feed lists and responsive grids.
///
/// Responsive strategy:
/// - [LayoutBuilder] picks line counts from the card's real width.
/// - The image sits inside [Expanded] so it absorbs leftover vertical
///   space in the grid cell instead of forcing a rigid 16:9 that can
///   push the content past the bottom edge.
/// - Every text child has an explicit `maxLines` + ellipsis, giving the
///   content column a bounded height that cannot overflow.
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        article.urlToImage != null && article.urlToImage!.isNotEmpty;
    final bool hasDescription = article.description.trim().isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        // Narrow cards get fewer lines so the content column's maximum
        // height still fits inside the grid cell.
        final bool isNarrow = width < 340;
        final int titleLines = isNarrow ? 2 : 3;
        final int descLines = isNarrow ? 1 : 2;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.cardBorderRadius,
            border: Border.all(color: AppColors.border),
            boxShadow: AppSpacing.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image absorbs whatever vertical space remains after the
                // content is laid out. BoxFit.cover keeps the visual
                // composition sane regardless of the exact height.
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Hero(
                      tag: heroTagFor(article),
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: article.urlToImage!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: AppColors.surfaceDim),
                              errorWidget: (_, __, ___) => SourcePlaceholder(
                                sourceName: article.source.name,
                              ),
                            )
                          : SourcePlaceholder(
                              sourceName: article.source.name,
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.source.name.toUpperCase(),
                        style: AppTextStyles.labelUppercase,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        article.title,
                        style: AppTextStyles.headlineSmall,
                        maxLines: titleLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // description is non-null — '' means "missing".
                      if (hasDescription) ...[
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          article.description.trim(),
                          style: AppTextStyles.bodyMedium,
                          maxLines: descLines,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.m),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Flexible so a long "3mo ago" string can never
                          // push the share icon off the right edge.
                          Flexible(
                            child: Text(
                              article.publishedAt != null
                                  ? TimeAgo.format(article.publishedAt!)
                                  : '',
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined, size: 18),
                            color: AppColors.textSecondary,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            onPressed: onShare,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}