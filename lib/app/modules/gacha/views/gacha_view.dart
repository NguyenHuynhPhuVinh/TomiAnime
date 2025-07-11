import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/gacha_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class GachaView extends GetView<GachaController> {
  const GachaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.gift,
              color: AppColors.gachaTheme,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            Text('Gacha System', style: AppTextStyles.h5),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: AppDecorations.appBarWithThemeColor(AppColors.gachaTheme),
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
                  gradient: AppDecorations.radialGradientWithColor(AppColors.gachaTheme),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.gift,
                  size: 80.r,
                  color: AppColors.gachaTheme,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Gacha System',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.gachaTheme,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Quay thưởng nhận vật phẩm hiếm',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Đang phát triển...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gachaTheme.withOpacity(0.7),
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
