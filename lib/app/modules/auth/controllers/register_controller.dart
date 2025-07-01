import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../utils/notification_helper.dart';

class RegisterController extends GetxController {
  final AuthService _authService = AuthService.instance;
  
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Observable states
  final isRegisterLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
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
  
  // Confirm password validation
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
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
  
  // Sign in with Google
  Future<void> signInWithGoogle() async {
    isGoogleLoading.value = true;

    final result = await _authService.signInWithGoogle();

    isGoogleLoading.value = false;

    if (result != null) {
      NotificationHelper.showSuccess(
        title: 'Đăng ký thành công',
        message: 'Chào mừng ${result.user?.displayName ?? 'bạn'} đến với TomiAnime!',
        duration: const Duration(seconds: 3),
      );

      // Đợi một chút để hiển thị thông báo rồi chuyển trang
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/home');
    }
  }
  
  // Navigate to login screen
  void goToLogin() {
    Get.back();
  }
}
