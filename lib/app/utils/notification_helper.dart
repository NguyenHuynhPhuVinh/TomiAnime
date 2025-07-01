import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_decorations.dart';

class NotificationHelper {
  // Sử dụng màu sắc từ AppColors
  static const Color _successColor = AppColors.success;
  static const Color _errorColor = AppColors.error;
  static const Color _warningColor = AppColors.warning;
  static const Color _infoColor = AppColors.info;
  static const Color _backgroundColor = AppColors.backgroundSecondary;
  static const Color _textColor = AppColors.textPrimary;

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
      borderRadius: AppDecorations.radiusL.topLeft.x,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      duration: duration,
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: AppDecorations.iconContainerWithColor(_successColor),
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
        style: AppTextStyles.withColor(AppTextStyles.buttonMedium, _textColor),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.withOpacity(AppTextStyles.bodyMedium, 0.8),
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
      borderRadius: AppDecorations.radiusL.topLeft.x,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      duration: duration,
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: AppDecorations.iconContainerWithColor(_errorColor),
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
        style: AppTextStyles.withColor(AppTextStyles.buttonMedium, _textColor),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.withOpacity(AppTextStyles.bodyMedium, 0.8),
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
      borderRadius: AppDecorations.radiusL.topLeft.x,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      duration: duration,
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: AppDecorations.iconContainerWithColor(_warningColor),
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
        style: AppTextStyles.withColor(AppTextStyles.buttonMedium, _textColor),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.withOpacity(AppTextStyles.bodyMedium, 0.8),
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
      borderRadius: AppDecorations.radiusL.topLeft.x,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      duration: duration,
      icon: Container(
        padding: EdgeInsets.all(8.w),
        decoration: AppDecorations.iconContainerWithColor(_infoColor),
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
        style: AppTextStyles.withColor(AppTextStyles.buttonMedium, _textColor),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.withOpacity(AppTextStyles.bodyMedium, 0.8),
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
      borderRadius: AppDecorations.radiusL.topLeft.x,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      duration: const Duration(seconds: 10), // Thời gian dài hơn cho loading
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: _infoColor.withOpacity(0.3),
      progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(_infoColor),
      titleText: Text(
        'Đang xử lý',
        style: AppTextStyles.withColor(AppTextStyles.buttonMedium, _textColor),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.withOpacity(AppTextStyles.bodyMedium, 0.8),
      ),
    );
  }

  /// Ẩn tất cả snackbar hiện tại
  static void hideAll() {
    Get.closeAllSnackbars();
  }
}
