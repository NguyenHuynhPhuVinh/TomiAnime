import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/anime_model.dart';
import '../../../services/jikan_api_service.dart';

class AnimeController extends GetxController with GetSingleTickerProviderStateMixin {
  final JikanApiService _apiService = JikanApiService();

  // Tab controller cho 4 mùa
  late TabController tabController;

  // Observable variables
  final RxList<AnimeModel> animeList = <AnimeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasNextPage = true.obs;

  // Filter options
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxString selectedType = 'tv'.obs; // all, tv, movie, ova, special, ona, music

  // Seasons
  final List<String> seasons = ['winter', 'spring', 'summer', 'fall'];
  final List<String> seasonNames = ['Mùa Đông', 'Mùa Xuân', 'Mùa Hè', 'Mùa Thu'];

  // Type options
  final List<Map<String, String>> typeOptions = [
    {'value': 'all', 'label': 'Tất cả'},
    {'value': 'tv', 'label': 'TV'},
    {'value': 'movie', 'label': 'Movie'},
    {'value': 'ova', 'label': 'OVA'},
    {'value': 'special', 'label': 'Special'},
    {'value': 'ona', 'label': 'ONA'},
    {'value': 'music', 'label': 'Music'},
  ];



  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(_onTabChanged);
    loadCurrentSeasonAnime();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      // Reset pagination khi chuyển tab mùa
      currentPage.value = 1;
      animeList.clear();
      hasNextPage.value = true;
      loadSeasonAnime(refresh: true);
    }
  }

  String get currentSeason {
    final month = DateTime.now().month;
    if (month >= 12 || month <= 2) return 'winter';
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    return 'fall';
  }

  String get selectedSeason => seasons[tabController.index];

  void loadCurrentSeasonAnime() {
    final currentSeasonIndex = seasons.indexOf(currentSeason);
    if (currentSeasonIndex != -1) {
      tabController.animateTo(currentSeasonIndex);
    }
    loadSeasonAnime();
  }

  Future<void> loadSeasonAnime({bool refresh = true}) async {
    if (refresh) {
      currentPage.value = 1;
      animeList.clear();
      hasNextPage.value = true;
    }

    // Ngăn load nhiều lần cùng lúc
    if (isLoading.value || isLoadingMore.value) return;

    // Ngăn load khi không còn page
    if (!refresh && !hasNextPage.value) return;

    try {
      if (refresh) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      error.value = '';

      final String filter = selectedType.value == 'all' ? '' : selectedType.value;

      SeasonAnimeResponse response;

      // Nếu là mùa hiện tại, dùng API current season
      if (selectedSeason == currentSeason && selectedYear.value == DateTime.now().year) {
        response = await _apiService.getCurrentSeason(
          page: currentPage.value,
          limit: 25,
          filter: filter.isEmpty ? null : filter,
        );
      } else {
        response = await _apiService.getSeasonAnime(
          year: selectedYear.value,
          season: selectedSeason,
          page: currentPage.value,
          limit: 25,
          filter: filter.isEmpty ? null : filter,
        );
      }

      // Xử lý dữ liệu và filter trùng lặp
      if (response.data.isNotEmpty) {
        // Tạo map để loại bỏ trùng lặp trong chính response
        final Map<int, AnimeModel> uniqueResponseData = {};
        for (final anime in response.data) {
          uniqueResponseData[anime.malId] = anime;
        }
        final List<AnimeModel> cleanResponseData = uniqueResponseData.values.toList();

        if (refresh) {
          animeList.value = cleanResponseData;
          print('Loaded ${cleanResponseData.length} unique anime (${response.data.length - cleanResponseData.length} duplicates in API response) for page ${currentPage.value}');
        } else {
          // Kiểm tra trùng lặp với dữ liệu hiện có
          final existingIds = animeList.map((anime) => anime.malId).toSet();
          final newAnime = cleanResponseData.where((anime) => !existingIds.contains(anime.malId)).toList();

          if (newAnime.isNotEmpty) {
            animeList.addAll(newAnime);
            // Đảm bảo không có trùng lặp
            _ensureUniqueAnimeList();
            print('Added ${newAnime.length} new anime (${cleanResponseData.length - newAnime.length} already existed) for page ${currentPage.value}');
          } else {
            print('All ${cleanResponseData.length} anime from page ${currentPage.value} already exist - stopping pagination');
            hasNextPage.value = false;
            return;
          }
        }

        // Chỉ tăng page khi có dữ liệu
        currentPage.value++;
      } else {
        print('No data received for page ${currentPage.value}');
        hasNextPage.value = false;
      }

      hasNextPage.value = response.pagination.hasNextPage;

    } catch (e) {
      error.value = e.toString();
      print('Error loading anime: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void onTypeChanged(String type) {
    selectedType.value = type;
    // Reset pagination khi thay đổi filter
    currentPage.value = 1;
    animeList.clear();
    hasNextPage.value = true;
    loadSeasonAnime(refresh: true);
  }

  void onYearChanged(int year) {
    selectedYear.value = year;
    // Reset pagination khi thay đổi năm
    currentPage.value = 1;
    animeList.clear();
    hasNextPage.value = true;
    loadSeasonAnime(refresh: true);
  }

  void loadMore() {
    if (!isLoadingMore.value && hasNextPage.value) {
      loadSeasonAnime(refresh: false);
    }
  }

  void refresh() {
    loadSeasonAnime(refresh: true);
  }

  // Helper method để đảm bảo danh sách anime luôn unique
  void _ensureUniqueAnimeList() {
    final Map<int, AnimeModel> uniqueAnime = {};
    for (final anime in animeList) {
      uniqueAnime[anime.malId] = anime;
    }
    if (uniqueAnime.length != animeList.length) {
      animeList.value = uniqueAnime.values.toList();
      print('Removed ${animeList.length - uniqueAnime.length} duplicate anime from list');
    }
  }
}
