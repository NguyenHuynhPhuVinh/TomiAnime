import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/cards_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class CardsView extends GetView<CardsController> {
  const CardsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.card,
              color: AppColors.cardsTheme,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            Text('Card Collection', style: AppTextStyles.h5),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: AppDecorations.appBarWithThemeColor(AppColors.cardsTheme),
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
                  gradient: AppDecorations.radialGradientWithColor(AppColors.cardsTheme),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.card,
                  size: 80.r,
                  color: AppColors.cardsTheme,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Card Collection',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.cardsTheme,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Thu thập và nâng cấp thẻ bài',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Đang phát triển...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.cardsTheme.withOpacity(0.7),
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
