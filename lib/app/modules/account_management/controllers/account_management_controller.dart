import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/user_model.dart';

class AccountManagementController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString selectedAvatarUrl = ''.obs;

  final _authService = AuthService.instance;
  final _firestoreService = FirestoreService.instance;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    displayNameController.dispose();
    super.onClose();
  }

  /// Tải dữ liệu user hiện tại
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final user = _authService.currentUser;
      if (user == null) return;

      final userModel = await _firestoreService.getUser(user.uid);
      if (userModel != null) {
        currentUser.value = userModel;
        displayNameController.text = userModel.displayName ?? '';
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải thông tin tài khoản',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Chọn avatar từ nhân vật anime
  Future<void> selectAnimeCharacterAvatar() async {
    final result = await Get.toNamed('/character-search');
    if (result != null && result is String) {
      selectedAvatarUrl.value = result;
    }
  }

  /// Cập nhật thông tin tài khoản
  Future<void> updateAccount() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isUpdating.value = true;
      final user = _authService.currentUser;
      if (user == null) return;

      // Chuẩn bị dữ liệu cập nhật
      String? newDisplayName = displayNameController.text.trim().isEmpty
          ? null
          : displayNameController.text.trim();
      String? newAvatarUrl = selectedAvatarUrl.value.isEmpty
          ? null
          : selectedAvatarUrl.value;

      print('🔄 Updating user: displayName=$newDisplayName, avatarUrl=$newAvatarUrl');

      // Kiểm tra xem có thay đổi gì không
      bool hasChanges = false;
      if (newDisplayName != null && newDisplayName != currentUser.value?.displayName) {
        hasChanges = true;
      }
      if (newAvatarUrl != null && newAvatarUrl != currentUser.value?.avatarUrl) {
        hasChanges = true;
      }

      if (!hasChanges && newDisplayName == null && newAvatarUrl == null) {
        Get.snackbar(
          'Thông báo',
          'Không có thay đổi nào để cập nhật',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Cập nhật thông tin
      final success = await _firestoreService.updateUser(
        user.uid,
        displayName: newDisplayName,
        avatarUrl: newAvatarUrl,
      );

      print('✅ Update result: $success');

      if (success) {
        // Cập nhật local data để hiển thị ngay
        if (currentUser.value != null) {
          currentUser.value = currentUser.value!.copyWith(
            displayName: newDisplayName,
            avatarUrl: newAvatarUrl ?? currentUser.value!.avatarUrl,
          );
        }

        selectedAvatarUrl.value = '';

        print('🔙 Going back to account view...');

        // Quay về trước, sau đó mới hiển thị snackbar
        Get.back(result: true);

        // Hiển thị snackbar sau khi đã quay về
        Get.snackbar(
          'Thành công',
          'Cập nhật thông tin thành công',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          'Không thể cập nhật thông tin',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Exception during update: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi cập nhật: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Validation cho display name
  String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Cho phép để trống
    }
    
    if (value.trim().length < 2) {
      return 'Tên hiển thị phải có ít nhất 2 ký tự';
    }
    
    if (value.trim().length > 50) {
      return 'Tên hiển thị không được quá 50 ký tự';
    }
    
    return null;
  }

  /// Xóa avatar đã chọn
  void clearSelectedAvatar() {
    selectedAvatarUrl.value = '';
  }
}
