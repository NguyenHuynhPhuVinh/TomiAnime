import 'package:flutter/material.dart';

/// Định nghĩa tất cả màu sắc được sử dụng trong ứng dụng TomiAnime
class AppColors {
  // Private constructor để ngăn việc tạo instance
  AppColors._();

  // ===== MAIN BRAND COLORS =====
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF5A4FCF);
  
  // ===== BACKGROUND COLORS =====
  static const Color backgroundPrimary = Color(0xFF0A0E27);
  static const Color backgroundSecondary = Color(0xFF1A1D29);
  static const Color backgroundTertiary = Color(0xFF1A1A2E);
  static const Color backgroundQuaternary = Color(0xFF16213E);
  
  // ===== TEXT COLORS =====
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B3B8);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color textDisabled = Color(0xFF6D6D6D);
  
  // ===== SEMANTIC COLORS =====
  static const Color success = Color(0xFF00D4AA);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFB800);
  static const Color info = Color(0xFF6C5CE7);
  
  // ===== THEME COLORS FOR TABS =====
  static const Color animeTheme = Color(0xFFFF4757);
  static const Color animeThemeLight = Color(0xFFFF6B7A);
  
  static const Color cardsTheme = Color(0xFF3742FA);
  static const Color cardsThemeLight = Color(0xFF5352ED);
  
  static const Color adventureTheme = Color(0xFF2ED573);
  static const Color adventureThemeLight = Color(0xFF7BED9F);
  
  static const Color gachaTheme = Color(0xFF8E44AD);
  static const Color gachaThemeLight = Color(0xFFA55EEA);
  
  static const Color accountTheme = Color(0xFFFF9F43);
  static const Color accountThemeLight = Color(0xFFFFB74D);
  
  // ===== SURFACE COLORS =====
  static const Color surface = Color(0xFF1E1E2E);
  static const Color surfaceVariant = Color(0xFF2A2A3A);
  static const Color outline = Color(0xFF3A3A4A);
  static const Color outlineVariant = Color(0xFF2A2A3A);
  
  // ===== OVERLAY COLORS =====
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  
  // ===== GRADIENT COLORS =====
  static const List<Color> primaryGradient = [primary, primaryLight];
  static const List<Color> backgroundGradient = [backgroundTertiary, backgroundQuaternary];
  static const List<Color> surfaceGradient = [surface, surfaceVariant];
  
  // ===== NAVIGATION COLORS =====
  static const Color navBarBackground = backgroundSecondary;
  static const Color navBarBorder = Color(0xFF2A2A3A);
  static const Color navBarShadow = Color(0x40000000);
  
  // ===== BUTTON COLORS =====
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = surface;
  static const Color buttonDisabled = Color(0xFF3A3A4A);
  
  // ===== INPUT COLORS =====
  static const Color inputBackground = surface;
  static const Color inputBorder = outline;
  static const Color inputBorderFocused = primary;
  static const Color inputBorderError = error;
  
  // ===== CARD COLORS =====
  static const Color cardBackground = surface;
  static const Color cardBorder = outline;
  
  // ===== HELPER METHODS =====
  
  /// Lấy màu theme theo index tab
  static Color getThemeColorByIndex(int index) {
    switch (index) {
      case 0:
        return animeTheme;
      case 1:
        return cardsTheme;
      case 2:
        return adventureTheme;
      case 3:
        return gachaTheme;
      case 4:
        return accountTheme;
      default:
        return primary;
    }
  }
  
  /// Lấy màu theme sáng theo index tab
  static Color getThemeColorLightByIndex(int index) {
    switch (index) {
      case 0:
        return animeThemeLight;
      case 1:
        return cardsThemeLight;
      case 2:
        return adventureThemeLight;
      case 3:
        return gachaThemeLight;
      case 4:
        return accountThemeLight;
      default:
        return primaryLight;
    }
  }
  
  /// Lấy gradient theo theme color
  static List<Color> getGradientByColor(Color color) {
    if (color == animeTheme) return [animeTheme, animeThemeLight];
    if (color == cardsTheme) return [cardsTheme, cardsThemeLight];
    if (color == adventureTheme) return [adventureTheme, adventureThemeLight];
    if (color == gachaTheme) return [gachaTheme, gachaThemeLight];
    if (color == accountTheme) return [accountTheme, accountThemeLight];
    return primaryGradient;
  }
  
  /// Tạo màu với opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Tạo màu shadow từ màu gốc
  static Color createShadow(Color color, {double opacity = 0.3}) {
    return color.withOpacity(opacity);
  }
}
