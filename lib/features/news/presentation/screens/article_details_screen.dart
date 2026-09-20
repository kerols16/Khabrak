import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khabark/core/api_data_source/models/article_model.dart';
import 'package:khabark/core/constants/app_spacing.dart';
import 'package:khabark/core/theme/app_colors.dart';
import 'package:khabark/core/theme/app_text_styles.dart';
import 'package:khabark/core/utils/time_ago.dart';
import 'package:khabark/core/widgets/primary_button.dart';
import 'package:khabark/core/widgets/source_placeholder.dart';
import 'package:khabark/features/news/presentation/utils/hero_tag.dart';

/// Editorial article detail screen with hero image and pinned external-link CTA.
class ArticleDetailsScreen extends StatelessWidget {
  final Article article;
  final VoidCallback onReadFull;
  final VoidCallback onShare;

  const ArticleDetailsScreen({
    super.key,
    required this.article,
    required this.onReadFull,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        article.urlToImage != null && article.urlToImage!.isNotEmpty;

    // Nullable publishedAt — build the metadata line only when available.
    final DateTime? published = article.publishedAt;
    final String? metaLine = published == null
        ? null
        : '${DateFormat.yMMMMd().format(published)} • ${TimeAgo.format(published)}';

    final String? author = article.author;
    final bool hasAuthor = author != null && author.trim().isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasImage)
                      SizedBox(
                        height: 320,
                        width: double.infinity,
                        child: Hero(
                          tag: heroTagFor(article),
                          child: CachedNetworkImage(
                            imageUrl: article.urlToImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: AppColors.surfaceDim),
                            errorWidget: (_, __, ___) => SourcePlaceholder(
                              sourceName: article.source.name,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 180,
                        color: AppColors.primaryLight,
                        alignment: Alignment.center,
                        child: SourcePlaceholder(
                          sourceName: article.source.name,
                        ),
                      ),
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                          vertical: AppSpacing.m,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.source.name.toUpperCase(),
                              style: AppTextStyles.labelUppercase,
                            ),
                            const SizedBox(height: AppSpacing.s),
                            Text(
                              article.title,
                              style: AppTextStyles.headlineLarge,
                            ),
                            const SizedBox(height: AppSpacing.m),
                            Row(
                              children: [
                                if (hasAuthor) ...[
                                  Expanded(
                                    child: Text(
                                      'By ${author.trim()}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                if (metaLine != null)
                                  Text(
                                    metaLine,
                                    style: AppTextStyles.bodySmall,
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.m),
                            const Divider(),
                            const SizedBox(height: AppSpacing.m),
                            // Non-null description; '' means missing.
                            if (article.description.trim().isNotEmpty)
                              Text(
                                article.description.trim(),
                                style: AppTextStyles.bodyLarge,
                              ),
                            const SizedBox(height: AppSpacing.l),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: AppSpacing.s),
                                  Expanded(
                                    child: Text(
                                      'Preview only. Read the full story on '
                                      "the publisher's website.",
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.s,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TranslucentCircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _TranslucentCircleButton(
                    icon: Icons.share_rounded,
                    onTap: onShare,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.border)),
                boxShadow: AppSpacing.cardShadow,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: PrimaryButton(
                    text: 'Read full article',
                    icon: Icons.open_in_new_rounded,
                    onPressed: onReadFull,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TranslucentCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TranslucentCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}