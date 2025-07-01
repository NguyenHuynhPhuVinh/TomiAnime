import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../utils/notification_helper.dart';
import '../utils/auth_validators.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = AuthService.instance;
  
  // Form controller
  final emailController = TextEditingController();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Observable states
  final isLoading = false.obs;
  final isEmailSent = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
  
  // Email validation
  String? validateEmail(String? value) => AuthValidators.validateEmail(value);
  
  // Reset password
  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    // Hiển thị thông báo đang xử lý
    NotificationHelper.showLoading(
      message: 'Đang gửi email đặt lại mật khẩu...',
    );

    final success = await _authService.resetPassword(emailController.text.trim());

    isLoading.value = false;

    // Ẩn thông báo loading
    NotificationHelper.hideAll();

    if (success) {
      isEmailSent.value = true;

      // Đợi 3 giây để người dùng đọc thông báo thành công rồi quay về login
      await Future.delayed(const Duration(seconds: 3));
      Get.back();
    }
  }
  
  // Resend email
  Future<void> resendEmail() async {
    if (emailController.text.trim().isEmpty) {
      NotificationHelper.showWarning(
        title: 'Cảnh báo',
        message: 'Vui lòng nhập email trước khi gửi lại',
      );
      return;
    }

    await resetPassword();
  }

  // Reset form state
  void resetForm() {
    isEmailSent.value = false;
    emailController.clear();
  }

  // Navigate back to login screen
  void goToLogin() {
    Get.back();
  }
}
