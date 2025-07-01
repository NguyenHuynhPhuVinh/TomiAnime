import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // Main splash content
          Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundPrimary,
              AppColors.backgroundSecondary,
              AppColors.backgroundTertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildLogo(),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildLoadingSection(),
                  ),
                  _buildVersionInfo(),
                ],
              ),
            ),
          ),
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo container với animation
          Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            width: controller.logoSize.value,
            height: controller.logoSize.value,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.animeTheme,
                  AppColors.animeThemeLight,
                ],
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.animeTheme.withOpacity(0.3),
                  blurRadius: 20.r,
                  spreadRadius: 5.r,
                ),
              ],
            ),
            child: Icon(
              Iconsax.play_circle,
              color: Colors.white,
              size: 80.r,
            ),
          )),
          SizedBox(height: 24.h),
          // App name với fade animation
          SizedBox(
            width: double.infinity,
            child: Obx(() => AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: controller.textOpacity.value,
              child: Text(
                'TomiAnime',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 36.sp,
                ),
                textAlign: TextAlign.center,
              ),
            )),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: Obx(() => AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: controller.textOpacity.value,
              child: Text(
                'Khám phá thế giới anime',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                ),
                textAlign: TextAlign.center,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Simple loading indicator
          SizedBox(
            width: 60.r,
            height: 60.r,
            child: CircularProgressIndicator(
              strokeWidth: 4.r,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.animeTheme,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          // Loading text
          SizedBox(
            width: double.infinity,
            child: Text(
              'Đang tải...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 12.h),
          // Loading detail text
          SizedBox(
            width: double.infinity,
            child: Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                controller.loadingText.value,
                key: ValueKey(controller.loadingText.value),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ),
        ],
      ),
    );
  }



  Widget _buildVersionInfo() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => AnimatedOpacity(
        duration: const Duration(milliseconds: 1000),
        opacity: controller.textOpacity.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Version 1.0.0',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              'Powered by TomiSakae',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )),
    );
  }
}
