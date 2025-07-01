import 'package:get/get.dart';
import '../../../models/anime_watch_status_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/notification_helper.dart';

class AnimeListController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final AuthService _authService = AuthService.instance;

  // Observable variables
  final RxList<AnimeWatchStatusModel> animeList = <AnimeWatchStatusModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<AnimeWatchStatus> status = AnimeWatchStatus.saved.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Lấy status từ arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['status'] != null) {
      final statusString = arguments['status'] as String;
      status.value = _parseStatus(statusString);
    }
    
    loadAnimeList();
  }

  /// Parse status string thành enum
  AnimeWatchStatus _parseStatus(String statusString) {
    switch (statusString) {
      case 'saved':
        return AnimeWatchStatus.saved;
      case 'watching':
        return AnimeWatchStatus.watching;
      case 'completed':
        return AnimeWatchStatus.completed;
      default:
        return AnimeWatchStatus.saved;
    }
  }

  /// Lấy tên hiển thị của status
  String getStatusDisplayName() {
    return status.value.displayName;
  }

  /// Thay đổi status và reload danh sách
  void changeStatus(AnimeWatchStatus newStatus) {
    if (status.value != newStatus) {
      status.value = newStatus;
      loadAnimeList();
    }
  }

  /// Tải danh sách anime theo trạng thái
  Future<void> loadAnimeList() async {
    try {
      isLoading.value = true;
      error.value = '';

      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User chưa đăng nhập');
      }

      print('🔄 Loading anime list with status: ${status.value.displayName}');

      final animes = await _firestoreService.getAnimesByStatus(user.uid, status.value);
      animeList.value = animes;

      print('✅ Loaded ${animes.length} animes with status: ${status.value.displayName}');
    } catch (e) {
      print('❌ Error loading anime list: $e');
      error.value = 'Không thể tải danh sách anime: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Xóa anime khỏi danh sách
  Future<void> deleteAnime(AnimeWatchStatusModel anime) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User chưa đăng nhập');
      }

      print('🗑️ Deleting anime: ${anime.title} (MAL ID: ${anime.malId})');

      final success = await _firestoreService.removeAnimeWatchStatus(user.uid, anime.malId);
      
      if (success) {
        // Xóa khỏi danh sách local
        animeList.removeWhere((item) => item.malId == anime.malId);

        NotificationHelper.showSuccess(
          title: 'Đã xóa',
          message: 'Đã xóa "${anime.title}" khỏi danh sách',
        );

        print('✅ Anime deleted successfully');
      } else {
        throw Exception('Không thể xóa anime');
      }
    } catch (e) {
      print('❌ Error deleting anime: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể xóa anime: ${e.toString()}',
      );
    }
  }

  /// Refresh danh sách
  Future<void> refresh() async {
    await loadAnimeList();
  }

  /// Lấy số lượng anime theo từng trạng thái (để hiển thị badge)
  Future<Map<AnimeWatchStatus, int>> getAnimeCountByStatus() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return {};

      final allAnimes = await _firestoreService.getAllWatchedAnimes(user.uid);
      
      final counts = <AnimeWatchStatus, int>{
        AnimeWatchStatus.saved: 0,
        AnimeWatchStatus.watching: 0,
        AnimeWatchStatus.completed: 0,
      };

      for (final anime in allAnimes) {
        counts[anime.status] = (counts[anime.status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('❌ Error getting anime count by status: $e');
      return {};
    }
  }

  /// Cập nhật trạng thái anime (nếu cần)
  Future<void> updateAnimeStatus(AnimeWatchStatusModel anime, AnimeWatchStatus newStatus) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final updatedAnime = anime.copyWith(
        status: newStatus,
        lastWatchedAt: DateTime.now(),
      );

      final success = await _firestoreService.saveAnimeWatchStatus(user.uid, updatedAnime);
      
      if (success) {
        // Cập nhật trong danh sách local nếu vẫn thuộc status hiện tại
        if (newStatus == status.value) {
          final index = animeList.indexWhere((item) => item.malId == anime.malId);
          if (index != -1) {
            animeList[index] = updatedAnime;
          }
        } else {
          // Xóa khỏi danh sách nếu status đã thay đổi
          animeList.removeWhere((item) => item.malId == anime.malId);
        }
        
        print('✅ Anime status updated: ${anime.title} -> ${newStatus.displayName}');
      }
    } catch (e) {
      print('❌ Error updating anime status: $e');
    }
  }

  /// Tìm kiếm anime trong danh sách
  void searchAnime(String query) {
    if (query.isEmpty) {
      loadAnimeList();
      return;
    }

    final filteredList = animeList.where((anime) {
      final titleMatch = anime.title.toLowerCase().contains(query.toLowerCase());
      final englishTitleMatch = anime.titleEnglish?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final japaneseTitle = anime.titleJapanese?.toLowerCase().contains(query.toLowerCase()) ?? false;
      
      return titleMatch || englishTitleMatch || japaneseTitle;
    }).toList();

    animeList.value = filteredList;
  }

  /// Sắp xếp danh sách anime
  void sortAnimeList(String sortBy) {
    switch (sortBy) {
      case 'title':
        animeList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'lastWatched':
        animeList.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));
        break;
      case 'progress':
        animeList.sort((a, b) => b.watchProgress.compareTo(a.watchProgress));
        break;
      case 'score':
        animeList.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
        break;
      default:
        animeList.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));
    }
  }
}
