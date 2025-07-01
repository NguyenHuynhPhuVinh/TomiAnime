import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_decorations.dart';

/// Theme chính của ứng dụng TomiAnime
class AppTheme {
  // Private constructor để ngăn việc tạo instance
  AppTheme._();

  /// Theme data cho ứng dụng
  static ThemeData get themeData => ThemeData(
    // ===== BRIGHTNESS =====
    brightness: Brightness.dark,
    useMaterial3: true,
    
    // ===== COLOR SCHEME =====
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryDark,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      surfaceVariant: AppColors.surfaceVariant,
      background: AppColors.backgroundPrimary,
      error: AppColors.error,
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: AppColors.textPrimary,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    ),
    
    // ===== SCAFFOLD =====
    scaffoldBackgroundColor: AppColors.backgroundPrimary,
    
    // ===== APP BAR =====
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h4,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    
    // ===== TEXT THEME =====
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1,
      displayMedium: AppTextStyles.h2,
      displaySmall: AppTextStyles.h3,
      headlineLarge: AppTextStyles.h3,
      headlineMedium: AppTextStyles.h4,
      headlineSmall: AppTextStyles.h5,
      titleLarge: AppTextStyles.h4,
      titleMedium: AppTextStyles.h5,
      titleSmall: AppTextStyles.bodyLarge,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.buttonLarge,
      labelMedium: AppTextStyles.buttonMedium,
      labelSmall: AppTextStyles.buttonSmall,
    ),
    
    // ===== BUTTON THEMES =====
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.textPrimary,
        textStyle: AppTextStyles.buttonLarge,
        shape: RoundedRectangleBorder(
          borderRadius: AppDecorations.radiusXL,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        textStyle: AppTextStyles.buttonLarge,
        shape: RoundedRectangleBorder(
          borderRadius: AppDecorations.radiusXL,
        ),
        side: const BorderSide(
          color: AppColors.outline,
          width: 1,
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.buttonMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppDecorations.radiusM,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    
    // ===== INPUT DECORATION =====
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: AppDecorations.radiusM,
        borderSide: const BorderSide(
          color: AppColors.inputBorder,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDecorations.radiusM,
        borderSide: const BorderSide(
          color: AppColors.inputBorder,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDecorations.radiusM,
        borderSide: const BorderSide(
          color: AppColors.inputBorderFocused,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppDecorations.radiusM,
        borderSide: const BorderSide(
          color: AppColors.inputBorderError,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppDecorations.radiusM,
        borderSide: const BorderSide(
          color: AppColors.inputBorderError,
          width: 2,
        ),
      ),
      labelStyle: AppTextStyles.bodyMedium,
      hintStyle: AppTextStyles.withColor(AppTextStyles.bodyMedium, AppColors.textTertiary),
      errorStyle: AppTextStyles.errorText,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    // ===== CARD THEME =====
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppDecorations.radiusL,
        side: const BorderSide(
          color: AppColors.cardBorder,
          width: 1,
        ),
      ),
      margin: EdgeInsets.all(8),
    ),
    
    // ===== BOTTOM NAVIGATION BAR =====
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.navBarBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    
    // ===== DIALOG THEME =====
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppDecorations.radiusL,
      ),
      titleTextStyle: AppTextStyles.h4,
      contentTextStyle: AppTextStyles.bodyMedium,
    ),
    
    // ===== SNACKBAR THEME =====
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.backgroundSecondary,
      contentTextStyle: AppTextStyles.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: AppDecorations.radiusL,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ),
    
    // ===== DIVIDER THEME =====
    dividerTheme: const DividerThemeData(
      color: AppColors.outline,
      thickness: 1,
      space: 1,
    ),
    
    // ===== ICON THEME =====
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),
    
    // ===== CHECKBOX THEME =====
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(AppColors.textPrimary),
      side: const BorderSide(
        color: AppColors.outline,
        width: 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppDecorations.radiusXS,
      ),
    ),
    
    // ===== RADIO THEME =====
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.outline;
      }),
    ),
    
    // ===== SWITCH THEME =====
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textTertiary;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary.withOpacity(0.3);
        }
        return AppColors.outline;
      }),
    ),
  );
}
