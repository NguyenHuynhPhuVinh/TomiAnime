import 'package:get/get.dart';
import 'auth_service.dart';

class AuthGuard {
  static String getInitialRoute() {
    final authService = Get.find<AuthService>();
    return authService.isLoggedIn ? '/home' : '/login';
  }
}
