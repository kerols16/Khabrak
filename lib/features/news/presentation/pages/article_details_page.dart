import 'package:flutter/material.dart';
import 'package:khabark/core/api_data_source/models/article_model.dart';
import 'package:khabark/features/news/presentation/screens/article_details_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailsPage extends StatelessWidget {
  final Article article;

  const ArticleDetailsPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return ArticleDetailsScreen(
      article: article,
      onReadFull: () => _openFull(context),
      onShare: () => _share(article.url),
    );
  }

  Future<void> _openFull(BuildContext context) async {
    final Uri uri = Uri.parse(article.url);
    try {
      final bool ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok && context.mounted) _snack(context);
    } catch (_) {
      if (context.mounted) _snack(context);
    }
  }

  void _snack(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Couldn't open the link.")));
  }

  void _share(String url) {
    SharePlus.instance.share(ShareParams(text: url));
  }
}
