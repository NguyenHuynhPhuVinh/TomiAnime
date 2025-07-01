import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationHelper {
  // Màu sắc cho theme dark
  static const Color _successColor = Color(0xFF00D4AA);
  static const Color _errorColor = Color(0xFFFF6B6B);
  static const Color _warningColor = Color(0xFFFFB800);
  static const Color _infoColor = Color(0xFF6C5CE7);
  static const Color _backgroundColor = Color(0xFF1A1D29);
  static const Color _textColor = Colors.white;

  /// Hiển thị thông báo thành công
  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _backgroundColor,
      colorText: _textColor,
      borderRadius: 16.r,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      duration: duration,
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: _successColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.check_circle,
          color: _successColor,
          size: 24.sp,
        ),
      ),
      borderColor: _successColor,
      borderWidth: 1,
      titleText: Text(
        title,
        style: TextStyle(
          color: _textColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: _textColor.withOpacity(0.8),
          fontSize: 14.sp,
        ),
      ),
    );
  }

  /// Hiển thị thông báo lỗi
  static void showError({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _backgroundColor,
      colorText: _textColor,
      borderRadius: 16.r,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      duration: duration,
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: _errorColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.error,
          color: _errorColor,
          size: 24.sp,
        ),
      ),
      borderColor: _errorColor,
      borderWidth: 1,
      titleText: Text(
        title,
        style: TextStyle(
          color: _textColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: _textColor.withOpacity(0.8),
          fontSize: 14.sp,
        ),
      ),
    );
  }

  /// Hiển thị thông báo cảnh báo
  static void showWarning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _backgroundColor,
      colorText: _textColor,
      borderRadius: 16.r,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      duration: duration,
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: _warningColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.warning,
          color: _warningColor,
          size: 24.sp,
        ),
      ),
      borderColor: _warningColor,
      borderWidth: 1,
      titleText: Text(
        title,
        style: TextStyle(
          color: _textColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: _textColor.withOpacity(0.8),
          fontSize: 14.sp,
        ),
      ),
    );
  }

  /// Hiển thị thông báo thông tin
  static void showInfo({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _backgroundColor,
      colorText: _textColor,
      borderRadius: 16.r,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      duration: duration,
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: _infoColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.info,
          color: _infoColor,
          size: 24.sp,
        ),
      ),
      borderColor: _infoColor,
      borderWidth: 1,
      titleText: Text(
        title,
        style: TextStyle(
          color: _textColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: _textColor.withOpacity(0.8),
          fontSize: 14.sp,
        ),
      ),
    );
  }

  /// Hiển thị thông báo loading với custom message
  static void showLoading({
    required String message,
  }) {
    Get.snackbar(
      'Đang xử lý',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _backgroundColor,
      colorText: _textColor,
      borderRadius: 12.r,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      duration: const Duration(seconds: 10), // Thời gian dài hơn cho loading
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: _infoColor.withOpacity(0.3),
      progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(_infoColor),
      titleText: Text(
        'Đang xử lý',
        style: TextStyle(
          color: _textColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: _textColor.withOpacity(0.8),
          fontSize: 14.sp,
        ),
      ),
    );
  }

  /// Ẩn tất cả snackbar hiện tại
  static void hideAll() {
    Get.closeAllSnackbars();
  }
}
