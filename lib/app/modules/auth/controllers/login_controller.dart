import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../utils/notification_helper.dart';
import 'base_auth_controller.dart';

class LoginController extends BaseAuthController {
  final AuthService _authService = AuthService.instance;

  // Observable states specific to login
  final isLoginLoading = false.obs;

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

  // Override methods from BaseAuthController
  @override
  String getGoogleSuccessTitle() => 'Đăng nhập thành công';

  @override
  String getGoogleSuccessMessage(dynamic result) =>
      'Chào mừng ${result.user?.displayName ?? 'bạn'} đến với TomiAnime!';

  // Navigate to register screen
  void goToRegister() {
    Get.toNamed('/register');
  }

  // Navigate to forgot password screen
  void goToForgotPassword() {
    Get.toNamed('/forgot-password');
  }
}
