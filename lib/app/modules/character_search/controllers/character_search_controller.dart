import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../models/character_model.dart';
import '../../../services/jikan_api_service.dart';
import '../../../utils/notification_helper.dart';

class CharacterSearchController extends GetxController {
  final searchController = TextEditingController();
  final RxList<CharacterModel> characters = <CharacterModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString searchText = ''.obs;

  final JikanApiService _apiService = JikanApiService();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchText.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Tìm kiếm nhân vật anime
  Future<void> searchCharacters(String query) async {
    if (query.trim().isEmpty) return;

    try {
      isLoading.value = true;
      hasSearched.value = true;
      searchQuery.value = query;
      characters.clear();

      final searchResponse = await _apiService.searchCharacters(
        query: query,
        limit: 20,
        orderBy: 'favorites',
        sort: 'desc',
      );

      characters.value = searchResponse.data
          .where((character) => character.images.imageUrl.isNotEmpty)
          .toList();

    } catch (e) {
      print('❌ Error searching characters: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể tìm kiếm nhân vật',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Chọn nhân vật và trả về URL ảnh
  void selectCharacter(CharacterModel character) {
    Get.back(result: character.images.imageUrl);
  }

  /// Xóa kết quả tìm kiếm
  void clearSearch() {
    searchController.clear();
    searchText.value = '';
    characters.clear();
    hasSearched.value = false;
    searchQuery.value = '';
  }
}
