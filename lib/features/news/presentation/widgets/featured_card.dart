import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:khabark/core/api_data_source/models/article_model.dart';
import 'package:khabark/core/constants/app_spacing.dart';
import 'package:khabark/core/theme/app_colors.dart';
import 'package:khabark/core/theme/app_text_styles.dart';
import 'package:khabark/core/utils/time_ago.dart';
import 'package:khabark/core/widgets/source_placeholder.dart';
import 'package:khabark/features/news/presentation/utils/hero_tag.dart';

class FeaturedCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const FeaturedCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        article.urlToImage != null && article.urlToImage!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.cardBorderRadius,
      child: ClipRRect(
        borderRadius: AppSpacing.cardBorderRadius,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: heroTagFor(article),
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: article.urlToImage!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: AppColors.surfaceDim),
                        errorWidget: (_, _, _) =>
                            SourcePlaceholder(sourceName: article.source.name),
                      )
                    : SourcePlaceholder(sourceName: article.source.name),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x33000000),
                      Color(0xCC000000),
                    ],
                    stops: [0.3, 0.6, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: AppSpacing.m,
                left: AppSpacing.m,
                right: AppSpacing.m,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.source.name.toUpperCase(),
                        style: AppTextStyles.labelUppercase.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      article.title,
                      style: AppTextStyles.headlineFeatured,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (article.publishedAt != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        TimeAgo.format(article.publishedAt!),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
