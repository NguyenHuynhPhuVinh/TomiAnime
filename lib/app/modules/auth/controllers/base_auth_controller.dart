import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../utils/notification_helper.dart';
import '../utils/auth_validators.dart';

abstract class BaseAuthController extends GetxController {
  final AuthService _authService = AuthService.instance;
  
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Observable states
  final isGoogleLoading = false.obs;
  final isPasswordVisible = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  // Validation methods
  String? validateEmail(String? value) => AuthValidators.validateEmail(value);
  String? validatePassword(String? value) => AuthValidators.validatePassword(value);
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  // Sign in with Google
  Future<void> signInWithGoogle() async {
    isGoogleLoading.value = true;

    final result = await _authService.signInWithGoogle();

    isGoogleLoading.value = false;

    if (result != null) {
      _handleGoogleSignInSuccess(result);
    }
  }
  
  // Handle Google sign-in success (to be implemented by subclasses)
  void _handleGoogleSignInSuccess(dynamic result) {
    NotificationHelper.showSuccess(
      title: getGoogleSuccessTitle(),
      message: getGoogleSuccessMessage(result),
      duration: const Duration(seconds: 2),
    );

    // Đợi một chút để hiển thị thông báo rồi chuyển trang
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.offAllNamed('/home');
    });
  }
  
  // Abstract methods to be implemented by subclasses
  String getGoogleSuccessTitle();
  String getGoogleSuccessMessage(dynamic result);
}
