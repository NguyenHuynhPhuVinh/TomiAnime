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

  // Filter và sort options
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxString selectedType = 'all'.obs; // all, tv, movie, ova, special, ona, music
  final RxString selectedSort = 'popularity'.obs; // popularity, score, title, start_date
  final RxString selectedOrder = 'desc'.obs; // desc, asc

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

  // Sort options
  final List<Map<String, String>> sortOptions = [
    {'value': 'popularity', 'label': 'Phổ biến'},
    {'value': 'score', 'label': 'Điểm số'},
    {'value': 'title', 'label': 'Tên'},
    {'value': 'start_date', 'label': 'Ngày phát sóng'},
    {'value': 'members', 'label': 'Thành viên'},
    {'value': 'favorites', 'label': 'Yêu thích'},
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
      loadSeasonAnime();
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

    if (isLoading.value || (!hasNextPage.value && !refresh)) return;

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
          filter: filter.isEmpty ? null : filter,
        );
      } else {
        response = await _apiService.getSeasonAnime(
          year: selectedYear.value,
          season: selectedSeason,
          page: currentPage.value,
          filter: filter.isEmpty ? null : filter,
        );
      }

      // Sort dữ liệu
      List<AnimeModel> sortedData = _sortAnimeList(response.data);

      if (refresh) {
        animeList.value = sortedData;
      } else {
        animeList.addAll(sortedData);
      }

      hasNextPage.value = response.pagination.hasNextPage;
      currentPage.value++;

    } catch (e) {
      error.value = e.toString();
      print('Error loading anime: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  List<AnimeModel> _sortAnimeList(List<AnimeModel> data) {
    List<AnimeModel> sortedData = List.from(data);

    switch (selectedSort.value) {
      case 'score':
        sortedData.sort((a, b) {
          final scoreA = a.score ?? 0;
          final scoreB = b.score ?? 0;
          return selectedOrder.value == 'desc'
              ? scoreB.compareTo(scoreA)
              : scoreA.compareTo(scoreB);
        });
        break;
      case 'title':
        sortedData.sort((a, b) {
          return selectedOrder.value == 'desc'
              ? b.title.compareTo(a.title)
              : a.title.compareTo(b.title);
        });
        break;
      case 'popularity':
        sortedData.sort((a, b) {
          final popA = a.popularity ?? 999999;
          final popB = b.popularity ?? 999999;
          return selectedOrder.value == 'desc'
              ? popA.compareTo(popB) // Popularity thấp hơn = phổ biến hơn
              : popB.compareTo(popA);
        });
        break;
      case 'members':
        sortedData.sort((a, b) {
          final membersA = a.members ?? 0;
          final membersB = b.members ?? 0;
          return selectedOrder.value == 'desc'
              ? membersB.compareTo(membersA)
              : membersA.compareTo(membersB);
        });
        break;
      case 'favorites':
        sortedData.sort((a, b) {
          final favA = a.favorites ?? 0;
          final favB = b.favorites ?? 0;
          return selectedOrder.value == 'desc'
              ? favB.compareTo(favA)
              : favA.compareTo(favB);
        });
        break;
    }

    return sortedData;
  }

  void onTypeChanged(String type) {
    selectedType.value = type;
    loadSeasonAnime();
  }

  void onSortChanged(String sort) {
    selectedSort.value = sort;
    loadSeasonAnime();
  }

  void onOrderChanged(String order) {
    selectedOrder.value = order;
    loadSeasonAnime();
  }

  void onYearChanged(int year) {
    selectedYear.value = year;
    loadSeasonAnime();
  }

  void loadMore() {
    if (!isLoadingMore.value && hasNextPage.value) {
      loadSeasonAnime(refresh: false);
    }
  }

  void refresh() {
    loadSeasonAnime(refresh: true);
  }
}
