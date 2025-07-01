import 'package:get/get.dart';
import '../../../models/nguonc_model.dart';
import '../../../services/nguonc_api_service.dart';

class AnimeWatchController extends GetxController {
  final NguoncApiService _apiService = NguoncApiService();

  // Observable variables
  final isLoading = true.obs;
  final error = ''.obs;
  final Rxn<NguoncMovie> movie = Rxn<NguoncMovie>();
  final selectedEpisodeIndex = 0.obs;

  // Parameters từ navigation
  late String nguoncUrl;
  late String animeTitle;
  late int malId;

  @override
  void onInit() {
    super.onInit();
    
    // Lấy parameters từ Get.arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    
    if (arguments != null) {
      nguoncUrl = arguments['nguoncUrl'] ?? '';
      animeTitle = arguments['animeTitle'] ?? '';
      malId = arguments['malId'] ?? 0;
      
      print('🎬 AnimeWatchController initialized:');
      print('   📋 MAL ID: $malId');
      print('   🏷️  Title: $animeTitle');
      print('   🔗 Nguonc URL: $nguoncUrl');
      
      if (nguoncUrl.isNotEmpty) {
        loadMovieDetails();
      } else {
        error.value = 'URL không hợp lệ';
        isLoading.value = false;
      }
    } else {
      error.value = 'Thiếu thông tin anime';
      isLoading.value = false;
    }
  }

  /// Load thông tin chi tiết phim từ Nguonc API
  Future<void> loadMovieDetails() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print('🔄 Loading movie details...');
      
      final response = await _apiService.getMovieDetails(nguoncUrl);
      
      if (response.status == 'success') {
        movie.value = response.movie;
        
        print('✅ Movie loaded successfully:');
        print('   🎭 Name: ${response.movie.name}');
        print('   📺 Total episodes: ${response.movie.totalEpisodes}');
        print('   🎥 Available episodes: ${response.movie.episodes.isNotEmpty ? response.movie.episodes.first.items.length : 0}');
        
        // Reset selected episode về đầu
        selectedEpisodeIndex.value = 0;
      } else {
        throw Exception('API trả về status không thành công: ${response.status}');
      }
    } catch (e) {
      print('❌ Error loading movie details: $e');
      error.value = 'Không thể tải thông tin anime: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Chọn tập phim
  void selectEpisode(int index) {
    if (movie.value != null && 
        movie.value!.episodes.isNotEmpty && 
        index >= 0 && 
        index < movie.value!.episodes.first.items.length) {
      selectedEpisodeIndex.value = index;
      
      final episode = movie.value!.episodes.first.items[index];
      print('📺 Selected episode: ${episode.name}');
      print('🔗 Embed URL: ${episode.embed}');
    }
  }

  /// Lấy tập hiện tại được chọn
  NguoncEpisode? get currentEpisode {
    if (movie.value != null && 
        movie.value!.episodes.isNotEmpty && 
        selectedEpisodeIndex.value < movie.value!.episodes.first.items.length) {
      return movie.value!.episodes.first.items[selectedEpisodeIndex.value];
    }
    return null;
  }

  /// Lấy danh sách tất cả tập phim
  List<NguoncEpisode> get allEpisodes {
    if (movie.value != null && movie.value!.episodes.isNotEmpty) {
      return movie.value!.episodes.first.items;
    }
    return [];
  }

  /// Chuyển đến tập tiếp theo
  void nextEpisode() {
    if (selectedEpisodeIndex.value < allEpisodes.length - 1) {
      selectEpisode(selectedEpisodeIndex.value + 1);
    }
  }

  /// Chuyển đến tập trước đó
  void previousEpisode() {
    if (selectedEpisodeIndex.value > 0) {
      selectEpisode(selectedEpisodeIndex.value - 1);
    }
  }

  /// Kiểm tra có tập tiếp theo không
  bool get hasNextEpisode {
    return selectedEpisodeIndex.value < allEpisodes.length - 1;
  }

  /// Kiểm tra có tập trước đó không
  bool get hasPreviousEpisode {
    return selectedEpisodeIndex.value > 0;
  }

  /// Refresh dữ liệu
  Future<void> refresh() async {
    await loadMovieDetails();
  }

  @override
  void onClose() {
    _apiService.dispose();
    super.onClose();
  }
}
