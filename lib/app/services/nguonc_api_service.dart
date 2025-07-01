import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/nguonc_model.dart';

class NguoncApiService {
  final Dio _dio = Dio();

  NguoncApiService() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptor for logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('🌐 Nguonc API: $obj'),
      ),
    );
  }

  /// Lấy thông tin chi tiết phim từ Nguonc API
  /// [url] - URL của API endpoint, ví dụ: "https://phim.nguonc.com/api/film/one-piece"
  Future<NguoncMovieResponse> getMovieDetails(String url) async {
    try {
      print('🎬 Fetching movie details from: $url');
      
      final response = await _dio.get(url);
      
      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Kiểm tra xem response có phải là JSON không
        Map<String, dynamic> jsonData;
        
        if (responseData is String) {
          // Nếu response là String, parse thành JSON
          print('🔧 Parsing string response to JSON...');
          jsonData = json.decode(responseData);
        } else if (responseData is Map<String, dynamic>) {
          // Nếu đã là Map, sử dụng trực tiếp
          jsonData = responseData;
        } else {
          throw Exception('Unexpected response type: ${responseData.runtimeType}');
        }
        
        print('✅ JSON data parsed successfully');
        final movieResponse = NguoncMovieResponse.fromJson(jsonData);
        
        // Log thông tin cơ bản
        print('🎭 Movie: ${movieResponse.movie.name}');
        print('📺 Total episodes: ${movieResponse.movie.totalEpisodes}');
        print('🎥 Available episodes: ${movieResponse.movie.episodes.isNotEmpty ? movieResponse.movie.episodes.first.items.length : 0}');
        
        return movieResponse;
      } else {
        throw Exception('Failed to fetch movie details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio error: ${e.message}');
      print('🔍 Error type: ${e.type}');
      
      if (e.response != null) {
        print('📊 Error response status: ${e.response?.statusCode}');
        print('📄 Error response data: ${e.response?.data}');
      }
      
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to fetch movie details: $e');
    }
  }

  /// Kiểm tra xem URL có hợp lệ không
  bool isValidNguoncUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.contains('nguonc.com') && 
             uri.path.contains('/api/film/');
    } catch (e) {
      return false;
    }
  }

  /// Lấy slug từ URL
  String? getSlugFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // URL format: https://phim.nguonc.com/api/film/SLUG
      if (pathSegments.length >= 3 && 
          pathSegments[0] == 'api' && 
          pathSegments[1] == 'film') {
        return pathSegments[2];
      }
      
      return null;
    } catch (e) {
      print('Error extracting slug from URL: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
