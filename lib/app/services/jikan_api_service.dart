import 'package:dio/dio.dart';
import '../models/anime_model.dart';

class JikanApiService {
  static const String baseUrl = 'https://api.jikan.moe/v4';
  late final Dio _dio;

  JikanApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptor for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  // Lấy anime theo mùa
  Future<SeasonAnimeResponse> getSeasonAnime({
    required int year,
    required String season,
    int page = 1,
    int limit = 25,
    String? filter, // tv, movie, ova, special, ona, music
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (filter != null && filter.isNotEmpty) {
        queryParams['filter'] = filter;
      }

      final response = await _dio.get(
        '/seasons/$year/$season',
        queryParameters: queryParams,
      );

      return SeasonAnimeResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu anime theo mùa: $e');
    }
  }

  // Lấy mùa hiện tại
  Future<SeasonAnimeResponse> getCurrentSeason({
    int page = 1,
    int limit = 25,
    String? filter,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (filter != null && filter.isNotEmpty) {
        queryParams['filter'] = filter;
      }

      final response = await _dio.get(
        '/seasons/now',
        queryParameters: queryParams,
      );

      return SeasonAnimeResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu anime mùa hiện tại: $e');
    }
  }

  // Lấy mùa sắp tới
  Future<SeasonAnimeResponse> getUpcomingSeason({
    int page = 1,
    int limit = 25,
    String? filter,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (filter != null && filter.isNotEmpty) {
        queryParams['filter'] = filter;
      }

      final response = await _dio.get(
        '/seasons/upcoming',
        queryParameters: queryParams,
      );

      return SeasonAnimeResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu anime mùa sắp tới: $e');
    }
  }

  // Tìm kiếm anime
  Future<SeasonAnimeResponse> searchAnime({
    String? query,
    String? type, // tv, movie, ova, special, ona, music
    double? minScore,
    double? maxScore,
    String? status, // airing, complete, upcoming
    String? rating, // g, pg, pg13, r17, r, rx
    String? orderBy, // mal_id, title, type, rating, start_date, end_date, episodes, score, scored_by, rank, popularity, members, favorites
    String? sort, // desc, asc
    int page = 1,
    int limit = 25,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (minScore != null) {
        queryParams['min_score'] = minScore;
      }
      if (maxScore != null) {
        queryParams['max_score'] = maxScore;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (rating != null && rating.isNotEmpty) {
        queryParams['rating'] = rating;
      }
      if (orderBy != null && orderBy.isNotEmpty) {
        queryParams['order_by'] = orderBy;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      final response = await _dio.get(
        '/anime',
        queryParameters: queryParams,
      );

      return SeasonAnimeResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm anime: $e');
    }
  }

  // Lấy top anime
  Future<SeasonAnimeResponse> getTopAnime({
    String? type,
    String? filter, // airing, upcoming, bypopularity, favorite
    int page = 1,
    int limit = 25,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (filter != null && filter.isNotEmpty) {
        queryParams['filter'] = filter;
      }

      final response = await _dio.get(
        '/top/anime',
        queryParameters: queryParams,
      );

      return SeasonAnimeResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi lấy top anime: $e');
    }
  }

  // Lấy chi tiết anime
  Future<AnimeModel> getAnimeDetails(int malId) async {
    try {
      final response = await _dio.get('/anime/$malId');
      return AnimeModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Lỗi khi lấy chi tiết anime: $e');
    }
  }

  // Lấy anime relations (sequel, prequel, side story, etc.)
  Future<AnimeRelationsResponse> getAnimeRelations(int malId) async {
    try {
      final response = await _dio.get('/anime/$malId/relations');
      return AnimeRelationsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi lấy anime relations: $e');
    }
  }
}
