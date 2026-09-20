import 'package:khabark/core/api_data_source/models/article_model.dart';

/// Single source of truth for the shared Hero tag used by cards and the
/// details screen. Kept out of widgets so tags never drift.
String heroTagFor(Article a) => 'article_img_${a.url}';