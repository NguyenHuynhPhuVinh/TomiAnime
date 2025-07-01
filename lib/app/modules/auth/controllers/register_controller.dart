import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../utils/notification_helper.dart';
import 'base_auth_controller.dart';
import '../utils/auth_validators.dart';

class RegisterController extends BaseAuthController {
  final AuthService _authService = AuthService.instance;

  // Additional form controller for register
  final confirmPasswordController = TextEditingController();

  // Observable states specific to register
  final isRegisterLoading = false.obs;
  final isConfirmPasswordVisible = false.obs;

  @override
  void onClose() {
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Confirm password validation
  String? validateConfirmPassword(String? value) {
    return AuthValidators.validateConfirmPassword(value, passwordController.text);
  }
  
  // Sign up with email and password
  Future<void> signUpWithEmailAndPassword() async {
    if (!formKey.currentState!.validate()) return;

    isRegisterLoading.value = true;

    final result = await _authService.signUpWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    isRegisterLoading.value = false;

    if (result != null) {
      NotificationHelper.showSuccess(
        title: 'Tạo tài khoản thành công',
        message: 'Chào mừng bạn đến với TomiAnime! Hãy khám phá thế giới anime tuyệt vời.',
        duration: const Duration(seconds: 3),
      );

      // Đợi một chút để hiển thị thông báo rồi chuyển trang
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/home');
    }
  }
  
  // Override methods from BaseAuthController
  @override
  String getGoogleSuccessTitle() => 'Đăng ký thành công';

  @override
  String getGoogleSuccessMessage(dynamic result) =>
    'Chào mừng ${result.user?.displayName ?? 'bạn'} đến với TomiAnime!';
  
  // Navigate to login screen
  void goToLogin() {
    Get.back();
  }
}
