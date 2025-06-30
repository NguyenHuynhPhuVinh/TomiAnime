import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService.instance;
  
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  
  // Observable states
  final isLoginLoading = false.obs;
  final isRegisterLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoginMode = true.obs;
  
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
  
  // Toggle between login and register mode
  void toggleAuthMode() {
    isLoginMode.value = !isLoginMode.value;
    // Clear form when switching modes
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
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
  
  // Sign in with email and password
  Future<void> signInWithEmailAndPassword() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoginLoading.value = true;

    final result = await _authService.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    isLoginLoading.value = false;

    if (result != null) {
      Get.offAllNamed('/home');
    }
  }
  
  // Sign up with email and password
  Future<void> signUpWithEmailAndPassword() async {
    if (!registerFormKey.currentState!.validate()) return;

    isRegisterLoading.value = true;

    final result = await _authService.signUpWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    isRegisterLoading.value = false;

    if (result != null) {
      Get.snackbar(
        'Thành công',
        'Tài khoản đã được tạo thành công',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed('/home');
    }
  }
  
  // Sign in with Google
  Future<void> signInWithGoogle() async {
    isGoogleLoading.value = true;

    final result = await _authService.signInWithGoogle();

    isGoogleLoading.value = false;

    if (result != null) {
      Get.offAllNamed('/home');
    }
  }
  
  // Reset password
  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập email để đặt lại mật khẩu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Lỗi',
        'Email không hợp lệ',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // Reset password không cần loading state riêng vì không conflict với các nút khác
    await _authService.resetPassword(emailController.text.trim());
  }
}
