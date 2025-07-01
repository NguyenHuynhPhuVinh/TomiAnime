import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../models/anime_model.dart';

class StreamingDataService {
  static const String _boxName = 'streaming_data';
  static const String _dataKey = 'anime_streaming_data';
  static const String _versionKey = 'data_version';
  static const String _lastSyncKey = 'last_sync_time';

  // URL của JSON file trên GitHub - cập nhật URL này với repo thực của bạn
  // Format: https://raw.githubusercontent.com/USERNAME/REPO_NAME/BRANCH/anime_streaming.json
  static const String githubJsonUrl =
      'https://raw.githubusercontent.com/NguyenHuynhPhuVinh/TomiAnimeData/refs/heads/main/anime_streaming.json';

  late final Box _box;
  final Dio _dio = Dio();

  // Singleton pattern
  static final StreamingDataService _instance =
      StreamingDataService._internal();
  factory StreamingDataService() => _instance;
  StreamingDataService._internal();

  /// Khởi tạo Hive box
  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
      print('StreamingDataService initialized successfully');
    } catch (e) {
      print('Error initializing StreamingDataService: $e');
      rethrow;
    }
  }

  /// Kiểm tra xem anime có thể xem được không
  bool isAnimeAvailable(int malId) {
    try {
      final data = _getLocalStreamingData();
      if (data == null) {
        print('🔍 No local streaming data found');
        return false;
      }

      final isAvailable = data.animes.any((anime) => anime.malId == malId);
      print(
        '🔍 Checking MAL ID $malId: ${isAvailable ? 'AVAILABLE' : 'NOT AVAILABLE'}',
      );

      if (isAvailable) {
        final anime = data.animes.firstWhere((anime) => anime.malId == malId);
        print('   🎥 Found: ${anime.nguoncUrl}');
      }

      return isAvailable;
    } catch (e) {
      print('❌ Error checking anime availability: $e');
      return false;
    }
  }

  /// Lấy URL nguonc cho anime
  String? getNguoncUrl(int malId) {
    try {
      final data = _getLocalStreamingData();
      if (data == null) return null;

      final anime = data.animes.firstWhere(
        (anime) => anime.malId == malId,
        orElse: () => throw Exception('Anime not found'),
      );

      return anime.nguoncUrl;
    } catch (e) {
      print('Error getting nguonc URL: $e');
      return null;
    }
  }

  /// Sync dữ liệu từ GitHub
  Future<bool> syncFromGitHub() async {
    try {
      print('🔄 Starting sync from GitHub...');
      print('📡 URL: $githubJsonUrl');

      // Tải dữ liệu từ GitHub
      final response = await _dio.get(githubJsonUrl);

      print('📊 Response status: ${response.statusCode}');
      print('📋 Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        // Kiểm tra xem response có phải là JSON không
        final responseData = response.data;
        print('📄 Response type: ${responseData.runtimeType}');

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
        final remoteData = StreamingSyncData.fromJson(jsonData);
        print('📦 Remote data loaded: ${remoteData.animes.length} animes');

        // Kiểm tra xem có cần update không
        if (_needsUpdate(remoteData)) {
          await _saveStreamingData(remoteData);
          await _updateSyncTime();
          print('✅ Data synced successfully from GitHub');
          return true;
        } else {
          print('ℹ️ Local data is up to date');
          return false;
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error syncing from GitHub: $e');
      print('🔍 Error details: ${e.toString()}');
      return false;
    }
  }

  /// Kiểm tra xem có cần update không
  bool _needsUpdate(StreamingSyncData remoteData) {
    final localData = _getLocalStreamingData();

    if (localData == null) {
      print('No local data found, update needed');
      return true;
    }

    // So sánh version
    if (localData.version != remoteData.version) {
      print(
        'Version mismatch: local=${localData.version}, remote=${remoteData.version}',
      );
      return true;
    }

    // So sánh last update time
    if (localData.lastUpdate.isBefore(remoteData.lastUpdate)) {
      print('Remote data is newer');
      return true;
    }

    return false;
  }

  /// Lấy dữ liệu streaming từ local storage
  StreamingSyncData? _getLocalStreamingData() {
    try {
      final jsonString = _box.get(_dataKey);
      if (jsonString == null) {
        print('📦 No local streaming data found in storage');
        return null;
      }

      final jsonData = json.decode(jsonString);
      final data = StreamingSyncData.fromJson(jsonData);

      print('📦 Local streaming data loaded:');
      print('   📅 Version: ${data.version}');
      print('   🕒 Last update: ${data.lastUpdate}');
      print('   🎬 Total animes: ${data.animes.length}');

      // Debug: hiển thị danh sách anime có sẵn
      if (data.animes.isNotEmpty) {
        print('   📋 Available anime MAL IDs:');
        for (final anime in data.animes) {
          print('      • ${anime.malId} - ${anime.nguoncUrl}');
        }
      }

      return data;
    } catch (e) {
      print('❌ Error getting local streaming data: $e');
      return null;
    }
  }

  /// Lưu dữ liệu streaming vào local storage
  Future<void> _saveStreamingData(StreamingSyncData data) async {
    try {
      final jsonString = json.encode(data.toJson());
      await _box.put(_dataKey, jsonString);
      await _box.put(_versionKey, data.version);
      print('Streaming data saved to local storage');
    } catch (e) {
      print('Error saving streaming data: $e');
      rethrow;
    }
  }

  /// Cập nhật thời gian sync cuối
  Future<void> _updateSyncTime() async {
    try {
      await _box.put(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error updating sync time: $e');
    }
  }

  /// Lấy thời gian sync cuối
  DateTime? getLastSyncTime() {
    try {
      final timeString = _box.get(_lastSyncKey);
      if (timeString == null) return null;
      return DateTime.tryParse(timeString);
    } catch (e) {
      print('Error getting last sync time: $e');
      return null;
    }
  }

  /// Kiểm tra xem có cần sync không (dựa trên thời gian)
  /// Chỉ dùng để thông tin, không tự động sync
  bool shouldSync({Duration maxAge = const Duration(hours: 24)}) {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return true;

    return DateTime.now().difference(lastSync) > maxAge;
  }

  /// Lấy thông tin version hiện tại
  String? getCurrentVersion() {
    try {
      return _box.get(_versionKey);
    } catch (e) {
      print('Error getting current version: $e');
      return null;
    }
  }

  /// Xóa tất cả dữ liệu local
  Future<void> clearLocalData() async {
    try {
      await _box.clear();
      print('Local streaming data cleared');
    } catch (e) {
      print('Error clearing local data: $e');
    }
  }

  /// Lấy tổng số anime có thể xem
  int getAvailableAnimeCount() {
    final data = _getLocalStreamingData();
    return data?.animes.length ?? 0;
  }

  /// Lấy danh sách tất cả anime có thể xem
  List<AnimeStreamingModel> getAllAvailableAnimes() {
    final data = _getLocalStreamingData();
    return data?.animes ?? [];
  }
}
