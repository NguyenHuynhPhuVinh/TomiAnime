import 'package:get/get.dart';
import '../../../models/nguonc_model.dart';
import '../../../models/anime_watch_status_model.dart';
import '../../../models/anime_model.dart';
import '../../../services/nguonc_api_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/daily_quest_service.dart';
import '../../../models/daily_quest_model.dart';
import '../../daily_quest/controllers/daily_quest_controller.dart';

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
  late AnimeModel animeData; // Thêm data anime đầy đủ

  @override
  void onInit() {
    super.onInit();

    // Lấy parameters từ Get.arguments
    final arguments = Get.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      nguoncUrl = arguments['nguoncUrl'] ?? '';
      animeTitle = arguments['animeTitle'] ?? '';
      malId = arguments['malId'] ?? 0;
      animeData = arguments['animeData'] as AnimeModel; // Lấy data anime đầy đủ

      print('🎬 AnimeWatchController initialized:');
      print('   📋 MAL ID: $malId');
      print('   🏷️  Title: $animeTitle');
      print('   🔗 Nguonc URL: $nguoncUrl');
      print('   📊 Anime data: ${animeData.title} (${animeData.type})');

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
        print(
          '   🎥 Available episodes: ${response.movie.episodes.isNotEmpty ? response.movie.episodes.first.items.length : 0}',
        );

        // Reset selected episode về đầu
        selectedEpisodeIndex.value = 0;
      } else {
        throw Exception(
          'API trả về status không thành công: ${response.status}',
        );
      }
    } catch (e) {
      print('❌ Error loading movie details: $e');
      error.value = 'Không thể tải thông tin anime: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Chọn tập phim và đánh dấu đã xem
  void selectEpisode(int index) {
    if (movie.value != null &&
        movie.value!.episodes.isNotEmpty &&
        index >= 0 &&
        index < movie.value!.episodes.first.items.length) {
      selectedEpisodeIndex.value = index;

      final episode = movie.value!.episodes.first.items[index];
      print('📺 Selected episode: ${episode.name}');
      print('🔗 Embed URL: ${episode.embed}');

      // Đánh dấu tập đã xem
      _markEpisodeWatched(index);
    }
  }

  /// Đánh dấu tập đã xem trong Firestore
  Future<void> _markEpisodeWatched(int episodeIndex) async {
    try {
      final authService = AuthService.instance;
      final user = authService.currentUser;

      if (user != null && movie.value != null) {
        final firestoreService = FirestoreService.instance;

        // Kiểm tra xem anime đã có trong watch status chưa
        final existingStatus = await firestoreService.getAnimeWatchStatus(
          user.uid,
          malId,
        );

        if (existingStatus == null) {
          // Tạo watch status mới từ thông tin anime từ detail modal
          final newWatchStatus = AnimeWatchStatusModel.fromAnimeModel(
            animeData,
          );

          await firestoreService.saveAnimeWatchStatus(user.uid, newWatchStatus);
          print('✅ Auto-created watch status for $animeTitle');
        }

        // Đánh dấu tập đã xem (không truyền totalEpisodes để giữ nguyên data từ detail)
        await firestoreService.markEpisodeWatched(
          user.uid,
          malId,
          episodeIndex,
        );

        print('✅ Episode $episodeIndex marked as watched for anime $malId');

        // Đánh dấu nhiệm vụ xem tập anime
        await _markWatchEpisodeQuest();
      }
    } catch (e) {
      print('❌ Error marking episode as watched: $e');
    }
  }

  /// Đánh dấu nhiệm vụ xem tập anime
  Future<void> _markWatchEpisodeQuest() async {
    try {
      // Kiểm tra xem có DailyQuestController đang chạy không
      if (Get.isRegistered<DailyQuestController>()) {
        final questController = Get.find<DailyQuestController>();
        await questController.markWatchEpisodeQuest();
      } else {
        // Fallback: gọi trực tiếp service
        final authService = AuthService.instance;
        if (!authService.isLoggedIn) return;

        final questService = DailyQuestService.instance;
        final uid = authService.currentUser!.uid;

        await Future.wait([
          questService.updateQuestProgress(uid, QuestType.watchEpisode),
          questService.updateQuestProgress(uid, QuestType.watchMultipleEpisodes),
        ]);
      }

      print('✅ Marked watch episode quest');
    } catch (e) {
      print('❌ Error marking watch episode quest: $e');
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
