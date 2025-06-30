import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    
    // If user is not logged in and trying to access protected routes
    if (!authService.isLoggedIn && route != '/auth') {
      return const RouteSettings(name: '/auth');
    }
    
    // If user is logged in and trying to access auth page
    if (authService.isLoggedIn && route == '/auth') {
      return const RouteSettings(name: '/home');
    }
    
    return null;
  }
}
