import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/adventure_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class AdventureView extends GetView<AdventureController> {
  const AdventureView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.map,
              color: AppColors.adventureTheme,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            Text('Adventure Quest', style: AppTextStyles.h5),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: AppDecorations.appBarWithThemeColor(AppColors.adventureTheme),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDecorations.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  gradient: AppDecorations.radialGradientWithColor(AppColors.adventureTheme),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.map,
                  size: 80.r,
                  color: AppColors.adventureTheme,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Adventure Quest',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.adventureTheme,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Khám phá thế giới bí ẩn',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Đang phát triển...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.adventureTheme.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
