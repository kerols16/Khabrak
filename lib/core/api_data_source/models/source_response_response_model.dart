import 'package:khabark/core/api_data_source/models/source_model.dart';

class SourcesResponse {
  final String status;
  final List<Sources> sources;

  const SourcesResponse({required this.status, required this.sources});

  factory SourcesResponse.fromJson(Map<String, dynamic> json) {
    return SourcesResponse(
      status: json['status'] as String? ?? '',
      sources: (json['sources'] as List<dynamic>? ?? [])
          .map((e) => Sources.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'sources': sources.map((e) => e.toJson()).toList(),
      };
}
