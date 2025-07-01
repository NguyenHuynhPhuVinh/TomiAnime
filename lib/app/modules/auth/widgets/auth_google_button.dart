import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class AuthGoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final RxBool isLoading;
  final String text;

  const AuthGoogleButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: AppDecorations.radiusXL,
        boxShadow: AppDecorations.shadowLight,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading.value ? null : onPressed,
          borderRadius: BorderRadius.circular(25.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading.value)
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textTertiary),
                    ),
                  )
                else
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: AppDecorations.radiusXS,
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: AppTextStyles.withSize(AppTextStyles.buttonSmall, 12),
                      ),
                    ),
                  ),
                SizedBox(width: 12.w),
                Text(
                  isLoading.value ? 'Đang đăng nhập...' : text,
                  style: AppTextStyles.withColor(AppTextStyles.buttonLarge, AppColors.backgroundPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
