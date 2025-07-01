import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

/// Định nghĩa tất cả text styles được sử dụng trong ứng dụng TomiAnime
class AppTextStyles {
  // Private constructor để ngăn việc tạo instance
  AppTextStyles._();

  // ===== HEADING STYLES =====
  
  /// Heading 1 - Tiêu đề chính lớn nhất (32sp)
  static TextStyle get h1 => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  /// Heading 2 - Tiêu đề phụ lớn (28sp)
  static TextStyle get h2 => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  /// Heading 3 - Tiêu đề trung bình (24sp)
  static TextStyle get h3 => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  /// Heading 4 - Tiêu đề nhỏ (20sp)
  static TextStyle get h4 => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );
  
  /// Heading 5 - Tiêu đề rất nhỏ (18sp)
  static TextStyle get h5 => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );
  
  // ===== BODY STYLES =====
  
  /// Body Large - Văn bản chính lớn (16sp)
  static TextStyle get bodyLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  /// Body Medium - Văn bản chính trung bình (14sp)
  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  /// Body Small - Văn bản chính nhỏ (12sp)
  static TextStyle get bodySmall => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
    letterSpacing: 0.2,
    height: 1.4,
  );
  
  // ===== BUTTON STYLES =====
  
  /// Button Large - Text cho button lớn (16sp)
  static TextStyle get buttonLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.2,
  );
  
  /// Button Medium - Text cho button trung bình (14sp)
  static TextStyle get buttonMedium => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
    height: 1.2,
  );
  
  /// Button Small - Text cho button nhỏ (12sp)
  static TextStyle get buttonSmall => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
    height: 1.2,
  );
  
  // ===== CAPTION STYLES =====
  
  /// Caption Large - Chú thích lớn (12sp)
  static TextStyle get captionLarge => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
    letterSpacing: 0.3,
    height: 1.3,
  );
  
  /// Caption Medium - Chú thích trung bình (10sp)
  static TextStyle get captionMedium => TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
    letterSpacing: 0.3,
    height: 1.3,
  );
  
  /// Caption Small - Chú thích nhỏ (8sp)
  static TextStyle get captionSmall => TextStyle(
    fontSize: 8.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textDisabled,
    letterSpacing: 0.3,
    height: 1.2,
  );
  
  // ===== NAVIGATION STYLES =====
  
  /// Navigation Label - Text cho navigation items (10sp)
  static TextStyle get navLabel => TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.2,
  );
  
  /// Navigation Label Selected - Text cho navigation item được chọn (10sp)
  static TextStyle get navLabelSelected => TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.2,
  );
  
  // ===== SPECIAL STYLES =====
  
  /// App Title - Tiêu đề ứng dụng
  static TextStyle get appTitle => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  /// Error Text - Text cho thông báo lỗi
  static TextStyle get errorText => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
    letterSpacing: 0.2,
    height: 1.3,
  );
  
  /// Success Text - Text cho thông báo thành công
  static TextStyle get successText => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.success,
    letterSpacing: 0.2,
    height: 1.3,
  );
  
  // ===== HELPER METHODS =====
  
  /// Tạo text style với màu tùy chỉnh
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Tạo text style với font weight tùy chỉnh
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// Tạo text style với font size tùy chỉnh
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size.sp);
  }
  
  /// Tạo text style với opacity
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withOpacity(opacity));
  }
}
