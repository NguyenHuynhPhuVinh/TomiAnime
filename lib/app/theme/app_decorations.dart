import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

/// Định nghĩa tất cả decorations được sử dụng trong ứng dụng TomiAnime
class AppDecorations {
  // Private constructor để ngăn việc tạo instance
  AppDecorations._();

  // ===== BORDER RADIUS =====
  
  static BorderRadius get radiusXS => BorderRadius.circular(4.r);
  static BorderRadius get radiusS => BorderRadius.circular(8.r);
  static BorderRadius get radiusM => BorderRadius.circular(12.r);
  static BorderRadius get radiusL => BorderRadius.circular(16.r);
  static BorderRadius get radiusXL => BorderRadius.circular(20.r);
  static BorderRadius get radiusXXL => BorderRadius.circular(24.r);
  static BorderRadius get radiusRound => BorderRadius.circular(50.r);
  
  // ===== BOX SHADOWS =====
  
  /// Shadow nhẹ
  static List<BoxShadow> get shadowLight => [
    BoxShadow(
      color: AppColors.overlay,
      blurRadius: 4.r,
      offset: Offset(0, 2.h),
    ),
  ];
  
  /// Shadow trung bình
  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: AppColors.overlay,
      blurRadius: 8.r,
      offset: Offset(0, 4.h),
    ),
  ];
  
  /// Shadow đậm
  static List<BoxShadow> get shadowHeavy => [
    BoxShadow(
      color: AppColors.overlay,
      blurRadius: 16.r,
      offset: Offset(0, 8.h),
    ),
  ];
  
  /// Shadow với màu tùy chỉnh
  static List<BoxShadow> shadowWithColor(Color color, {double opacity = 0.3}) => [
    BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: 8.r,
      offset: Offset(0, 2.h),
    ),
  ];
  
  // ===== GRADIENTS =====
  
  /// Gradient nền chính
  static LinearGradient get backgroundGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppColors.backgroundGradient,
  );
  
  /// Gradient primary
  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.primaryGradient,
  );
  
  /// Gradient surface
  static LinearGradient get surfaceGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppColors.surfaceGradient,
  );
  
  /// Gradient với màu tùy chỉnh
  static LinearGradient gradientWithColor(Color color) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.getGradientByColor(color),
  );
  
  /// Radial gradient cho icon background
  static RadialGradient radialGradientWithColor(Color color) => RadialGradient(
    colors: [
      color.withOpacity(0.2),
      color.withOpacity(0.05),
    ],
  );
  
  // ===== CONTAINER DECORATIONS =====
  
  /// Container chính với nền và border radius
  static BoxDecoration get primaryContainer => BoxDecoration(
    color: AppColors.surface,
    borderRadius: radiusM,
    boxShadow: shadowLight,
  );
  
  /// Container với gradient
  static BoxDecoration get gradientContainer => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: radiusM,
    boxShadow: shadowLight,
  );
  
  /// Container card
  static BoxDecoration get cardContainer => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: radiusL,
    border: Border.all(
      color: AppColors.cardBorder,
      width: 1,
    ),
    boxShadow: shadowMedium,
  );
  
  /// Container input field
  static BoxDecoration get inputContainer => BoxDecoration(
    color: AppColors.inputBackground,
    borderRadius: radiusM,
    border: Border.all(
      color: AppColors.inputBorder,
      width: 1,
    ),
  );
  
  /// Container input field khi focus
  static BoxDecoration get inputContainerFocused => BoxDecoration(
    color: AppColors.inputBackground,
    borderRadius: radiusM,
    border: Border.all(
      color: AppColors.inputBorderFocused,
      width: 2,
    ),
    boxShadow: shadowWithColor(AppColors.primary, opacity: 0.2),
  );
  
  /// Container input field khi có lỗi
  static BoxDecoration get inputContainerError => BoxDecoration(
    color: AppColors.inputBackground,
    borderRadius: radiusM,
    border: Border.all(
      color: AppColors.inputBorderError,
      width: 2,
    ),
    boxShadow: shadowWithColor(AppColors.error, opacity: 0.2),
  );
  
  /// Container button primary
  static BoxDecoration get buttonPrimaryContainer => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: radiusXL,
    boxShadow: shadowWithColor(AppColors.primary, opacity: 0.3),
  );
  
  /// Container button secondary
  static BoxDecoration get buttonSecondaryContainer => BoxDecoration(
    color: AppColors.buttonSecondary,
    borderRadius: radiusXL,
    border: Border.all(
      color: AppColors.outline,
      width: 1,
    ),
  );
  
  /// Container với theme color
  static BoxDecoration containerWithThemeColor(Color themeColor, {bool isSelected = false}) => BoxDecoration(
    gradient: isSelected
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeColor.withOpacity(0.2),
              themeColor.withOpacity(0.1),
            ],
          )
        : null,
    borderRadius: radiusM,
    border: isSelected
        ? Border.all(color: themeColor.withOpacity(0.5), width: 1.5)
        : null,
    boxShadow: isSelected ? shadowWithColor(themeColor, opacity: 0.3) : null,
  );
  
  // ===== NAVIGATION DECORATIONS =====
  
  /// Navigation bar decoration
  static BoxDecoration get navBarDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.backgroundTertiary, AppColors.backgroundQuaternary],
    ),
    boxShadow: [
      BoxShadow(
        offset: Offset(0, -2.h),
        blurRadius: 20.r,
        color: AppColors.primary.withOpacity(0.2),
      ),
    ],
    border: Border(
      top: BorderSide(
        color: AppColors.primary.withOpacity(0.3),
        width: 1,
      ),
    ),
  );
  
  // ===== APP BAR DECORATIONS =====
  
  /// App bar với gradient theme color
  static BoxDecoration appBarWithThemeColor(Color themeColor) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        themeColor.withOpacity(0.1),
        themeColor.withOpacity(0.05),
      ],
    ),
  );
  
  // ===== NOTIFICATION DECORATIONS =====
  
  /// Container cho notification
  static BoxDecoration get notificationContainer => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: radiusL,
    border: Border.all(
      color: AppColors.outline,
      width: 1,
    ),
    boxShadow: shadowMedium,
  );
  
  /// Container cho notification với màu tùy chỉnh
  static BoxDecoration notificationContainerWithColor(Color color) => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: radiusL,
    border: Border.all(
      color: color,
      width: 1,
    ),
    boxShadow: shadowWithColor(color, opacity: 0.2),
  );

  // ===== ICON DECORATIONS =====

  /// Container cho icon với background tròn
  static BoxDecoration iconContainerWithColor(Color color) => BoxDecoration(
    color: color.withOpacity(0.2),
    borderRadius: radiusM,
  );

  /// Container cho icon với background tròn và shadow
  static BoxDecoration iconContainerWithShadow(Color color) => BoxDecoration(
    color: color.withOpacity(0.2),
    borderRadius: radiusM,
    boxShadow: shadowWithColor(color, opacity: 0.3),
  );
}
