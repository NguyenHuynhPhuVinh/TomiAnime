import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Auth routes that don't require authentication
    final authRoutes = ['/login', '/register', '/forgot-password'];

    // If user is not logged in and trying to access protected routes
    if (!authService.isLoggedIn && !authRoutes.contains(route)) {
      return const RouteSettings(name: '/login');
    }

    // If user is logged in and trying to access auth pages
    if (authService.isLoggedIn && authRoutes.contains(route)) {
      return const RouteSettings(name: '/home');
    }

    return null;
  }
}
