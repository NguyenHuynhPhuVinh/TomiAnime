import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AnimeUtils {
  // Format số thành dạng K, M
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Widget placeholder cho ảnh đang load
  static Widget buildImagePlaceholder() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Icon(Iconsax.image, color: AppColors.textSecondary, size: 32.r),
      ),
    );
  }

  // Widget error cho ảnh load lỗi
  static Widget buildImageError() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Icon(
          Iconsax.warning_2,
          color: AppColors.textSecondary,
          size: 32.r,
        ),
      ),
    );
  }

  // Widget info row cho detail modal
  static Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
