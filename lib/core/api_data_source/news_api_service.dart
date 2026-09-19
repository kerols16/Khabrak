import 'package:dio/dio.dart';
import 'package:khabark/core/api_data_source/models/news_response_model.dart';
import 'package:khabark/core/api_data_source/models/source_response_response_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:khabark/core/constants/api_constants.dart';

part 'news_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class NewsApiService {
  factory NewsApiService(Dio dio, {String baseUrl}) = _NewsApiService;

  @GET(ApiConstants.everything)
  Future<NewsResponse> getEverything({
    @Query('q') String? q,
    @Query('searchIn') String? searchIn,
    @Query('sources') String? sources,
    @Query('domains') String? domains,
    @Query('excludeDomains') String? excludeDomains,
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('language') String? language,
    @Query('sortBy') String? sortBy,
    @Query('pageSize') int? pageSize,
    @Query('page') int? page,
  });

  @GET(ApiConstants.topHeadlines)
  Future<NewsResponse> getTopHeadlines({
    @Query('country') String? country,
    @Query('category') String? category,
    @Query('sources') String? sources,
    @Query('q') String? q,
    @Query('pageSize') int? pageSize,
    @Query('page') int? page,
  });

  @GET(ApiConstants.sources)
  Future<SourcesResponse> getSources({
    @Query('category') String? category,
    @Query('language') String? language,
    @Query('country') String? country,
  });
}