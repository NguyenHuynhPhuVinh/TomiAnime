import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/anime_model.dart';
import '../../../services/jikan_api_service.dart';

class AnimeSearchController extends GetxController {
  final JikanApiService _apiService = JikanApiService();

  // Text controller cho search input
  final TextEditingController searchController = TextEditingController();

  // Observable variables
  final RxList<AnimeModel> searchResults = <AnimeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasNextPage = true.obs;
  final RxString currentQuery = ''.obs;

  // Search filters
  final RxString selectedType = 'all'.obs;
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedRating = 'all'.obs;
  final RxDouble minScore = 0.0.obs;
  final RxDouble maxScore = 10.0.obs;
  final RxBool sfw = true.obs;

  // Filter options
  final List<Map<String, String>> typeOptions = [
    {'value': 'all', 'label': 'Tất cả'},
    {'value': 'tv', 'label': 'TV'},
    {'value': 'movie', 'label': 'Movie'},
    {'value': 'ova', 'label': 'OVA'},
    {'value': 'special', 'label': 'Special'},
    {'value': 'ona', 'label': 'ONA'},
    {'value': 'music', 'label': 'Music'},
    {'value': 'cm', 'label': 'CM'},
    {'value': 'pv', 'label': 'PV'},
    {'value': 'tv_special', 'label': 'TV Special'},
  ];

  final List<Map<String, String>> statusOptions = [
    {'value': 'all', 'label': 'Tất cả'},
    {'value': 'airing', 'label': 'Đang phát sóng'},
    {'value': 'complete', 'label': 'Hoàn thành'},
    {'value': 'upcoming', 'label': 'Sắp ra mắt'},
  ];

  final List<Map<String, String>> ratingOptions = [
    {'value': 'all', 'label': 'Tất cả'},
    {'value': 'g', 'label': 'G - Mọi lứa tuổi'},
    {'value': 'pg', 'label': 'PG - Trẻ em'},
    {'value': 'pg13', 'label': 'PG-13 - 13+ tuổi'},
    {'value': 'r17', 'label': 'R - 17+ tuổi'},
    {'value': 'r', 'label': 'R+ - Có nội dung nhạy cảm'},
    {'value': 'rx', 'label': 'Rx - Hentai'},
  ];

  final List<Map<String, String>> scoreOptions = [
    {'value': 'all', 'label': 'Tất cả'},
    {'value': '9+', 'label': '9.0+ ⭐'},
    {'value': '8+', 'label': '8.0+ ⭐'},
    {'value': '7+', 'label': '7.0+ ⭐'},
    {'value': '6+', 'label': '6.0+ ⭐'},
  ];

  final RxString selectedScore = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to text changes để update currentQuery
    searchController.addListener(() {
      if (searchController.text.trim() != currentQuery.value) {
        currentQuery.value = searchController.text.trim();
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> searchAnime({bool refresh = true}) async {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    if (refresh) {
      currentPage.value = 1;
      searchResults.clear();
      hasNextPage.value = true;
      currentQuery.value = query;
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

      // Xử lý score filter
      double? apiMinScore;
      if (selectedScore.value != 'all') {
        switch (selectedScore.value) {
          case '9+':
            apiMinScore = 9.0;
            break;
          case '8+':
            apiMinScore = 8.0;
            break;
          case '7+':
            apiMinScore = 7.0;
            break;
          case '6+':
            apiMinScore = 6.0;
            break;
        }
      }

      final response = await _apiService.searchAnime(
        query: currentQuery.value,
        type: selectedType.value == 'all' ? null : selectedType.value,
        status: selectedStatus.value == 'all' ? null : selectedStatus.value,
        rating: selectedRating.value == 'all' ? null : selectedRating.value,
        minScore: apiMinScore ?? (minScore.value > 0 ? minScore.value : null),
        maxScore: maxScore.value < 10 ? maxScore.value : null,
        page: currentPage.value,
        limit: 25,
      );

      // Xử lý dữ liệu và filter trùng lặp
      if (response.data.isNotEmpty) {
        // Tạo map để loại bỏ trùng lặp trong chính response
        final Map<int, AnimeModel> uniqueResponseData = {};
        for (final anime in response.data) {
          uniqueResponseData[anime.malId] = anime;
        }
        final List<AnimeModel> cleanResponseData = uniqueResponseData.values
            .toList();

        if (refresh) {
          searchResults.value = cleanResponseData;
          print(
            'Found ${cleanResponseData.length} unique anime (${response.data.length - cleanResponseData.length} duplicates in API response) for query: "$query"',
          );
        } else {
          // Kiểm tra trùng lặp với dữ liệu hiện có
          final existingIds = searchResults.map((anime) => anime.malId).toSet();
          final newAnime = cleanResponseData
              .where((anime) => !existingIds.contains(anime.malId))
              .toList();

          if (newAnime.isNotEmpty) {
            searchResults.addAll(newAnime);
            print(
              'Added ${newAnime.length} new anime (${cleanResponseData.length - newAnime.length} already existed) for page ${currentPage.value}',
            );
          } else {
            print(
              'All ${cleanResponseData.length} anime from page ${currentPage.value} already exist - stopping pagination',
            );
            hasNextPage.value = false;
            return;
          }
        }

        hasNextPage.value = response.pagination.hasNextPage;
        currentPage.value++;
      } else {
        print('No search results for query: "$query"');
        if (refresh) {
          searchResults.clear();
        }
        hasNextPage.value = false;
      }
    } catch (e) {
      error.value = e.toString();
      print('Error searching anime: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void loadMore() {
    if (!isLoadingMore.value &&
        hasNextPage.value &&
        currentQuery.value.isNotEmpty) {
      searchAnime(refresh: false);
    }
  }

  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    currentQuery.value = '';
    currentPage.value = 1;
    hasNextPage.value = true;
    error.value = '';
  }

  void onFilterChanged() {
    if (currentQuery.value.isNotEmpty) {
      searchAnime(refresh: true);
    }
  }

  void resetFilters() {
    selectedType.value = 'all';
    selectedStatus.value = 'all';
    selectedRating.value = 'all';
    selectedScore.value = 'all';
    minScore.value = 0.0;
    maxScore.value = 10.0;
    sfw.value = true;

    if (currentQuery.value.isNotEmpty) {
      searchAnime(refresh: true);
    }
  }
}
