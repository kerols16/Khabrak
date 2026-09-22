import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class EmptyView extends StatelessWidget {
  final String query;
  final VoidCallback? onClear;

  const EmptyView({super.key, required this.query, this.onClear});

  @override
  Widget build(BuildContext context) {
    final bool hasQuery = query.trim().isNotEmpty;
    final String title = hasQuery
        ? 'No results for "$query"'
        : 'No articles found';
    final String hint = hasQuery
        ? 'Try checking for typos or searching for a different keyword.'
        : 'Try another category.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceDim,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.textSecondary,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              title,
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              hint,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (hasQuery && onClear != null) ...[
              const SizedBox(height: AppSpacing.l),
              OutlinedButton(
                onPressed: onClear,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(140, 44),
                ),
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
