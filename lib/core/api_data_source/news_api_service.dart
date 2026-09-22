import 'package:dio/dio.dart';
import 'package:khabark/core/api_data_source/models/news_response_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:khabark/core/constants/api_constants.dart';

part 'news_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class NewsApiService {
  factory NewsApiService(Dio dio, {String baseUrl}) = _NewsApiService;

  @GET(ApiConstants.topHeadlines)
  Future<NewsResponse> getTopHeadlines({
    @Query('country') String? country,
    @Query('category') String? category,
    @Query('sources') String? sources,
    @Query('q') String? q,
    @Query('pageSize') int? pageSize,
    @Query('page') int? page,
  });
}
