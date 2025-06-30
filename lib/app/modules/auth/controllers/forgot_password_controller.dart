import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = AuthService.instance;
  
  // Form controller
  final emailController = TextEditingController();
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  // Observable states
  final isLoading = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
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
  
  // Reset password
  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;
    
    isLoading.value = true;
    
    await _authService.resetPassword(emailController.text.trim());
    
    isLoading.value = false;
    
    // Navigate back to login after successful reset
    Get.back();
  }
  
  // Navigate back to login screen
  void goToLogin() {
    Get.back();
  }
}
