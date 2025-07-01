import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../utils/notification_helper.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService.instance;
  
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Observable states
  final isLoginLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isPasswordVisible = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }
  
  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }
  
  // Sign in with email and password
  Future<void> signInWithEmailAndPassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoginLoading.value = true;

    final result = await _authService.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    isLoginLoading.value = false;

    if (result != null) {
      NotificationHelper.showSuccess(
        title: 'Đăng nhập thành công',
        message: 'Chào mừng bạn quay trở lại!',
        duration: const Duration(seconds: 2),
      );

      // Đợi một chút để hiển thị thông báo rồi chuyển trang
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/home');
    }
  }
  
  // Sign in with Google
  Future<void> signInWithGoogle() async {
    isGoogleLoading.value = true;

    final result = await _authService.signInWithGoogle();

    isGoogleLoading.value = false;

    if (result != null) {
      NotificationHelper.showSuccess(
        title: 'Đăng nhập thành công',
        message: 'Chào mừng ${result.user?.displayName ?? 'bạn'} đến với TomiAnime!',
        duration: const Duration(seconds: 2),
      );

      // Đợi một chút để hiển thị thông báo rồi chuyển trang
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/home');
    }
  }
  
  // Navigate to register screen
  void goToRegister() {
    Get.toNamed('/register');
  }
  
  // Navigate to forgot password screen
  void goToForgotPassword() {
    Get.toNamed('/forgot-password');
  }
}
