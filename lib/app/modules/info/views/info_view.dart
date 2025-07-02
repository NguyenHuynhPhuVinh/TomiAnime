import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/info_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class InfoView extends GetView<InfoController> {
  const InfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.info_circle,
              color: AppColors.accountTheme,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            Text('Thông tin ứng dụng', style: AppTextStyles.h5),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
          onPressed: () => Get.back(),
        ),
        flexibleSpace: Container(
          decoration: AppDecorations.appBarWithThemeColor(
            AppColors.accountTheme,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppDecorations.backgroundGradient),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.accountTheme,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                _buildAppInfo(),
                SizedBox(height: 30.h),
                _buildDeveloperInfo(),
                SizedBox(height: 30.h),
                _buildVersionInfo(),
                SizedBox(height: 30.h),
                _buildBuildInfo(),
                SizedBox(height: 30.h),
                _buildPackageInfo(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accountTheme.withOpacity(0.1),
            AppColors.accountThemeLight.withOpacity(0.05),
          ],
        ),
        borderRadius: AppDecorations.radiusL,
        border: Border.all(
          color: AppColors.accountTheme.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: AppDecorations.radialGradientWithColor(
                AppColors.accountTheme,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.mobile,
              size: 60.r,
              color: AppColors.accountTheme,
            ),
          ),
          SizedBox(height: 16.h),
          Text(controller.appName, style: AppTextStyles.h3),
          SizedBox(height: 8.h),
          Text(
            'Ứng dụng xem anime miễn phí',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return _buildInfoCard(
      icon: Iconsax.code,
      title: 'Nhà phát triển',
      content: 'TomiSakae',
      subtitle: 'Phát triển với ❤️ bằng Flutter',
    );
  }

  Widget _buildVersionInfo() {
    return _buildInfoCard(
      icon: Iconsax.tag,
      title: 'Phiên bản',
      content: controller.version,
      subtitle: 'Phiên bản hiện tại',
    );
  }

  Widget _buildBuildInfo() {
    return _buildInfoCard(
      icon: Iconsax.code_circle,
      title: 'Build Number',
      content: controller.buildNumber,
      subtitle: 'Số build hiện tại',
    );
  }

  Widget _buildPackageInfo() {
    return _buildInfoCard(
      icon: Iconsax.box,
      title: 'Package Name',
      content: controller.packageName,
      subtitle: 'Tên gói ứng dụng',
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.radiusM,
        border: Border.all(
          color: AppColors.accountTheme.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: AppDecorations.iconContainerWithColor(
              AppColors.accountTheme,
            ),
            child: Icon(icon, color: AppColors.accountTheme, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.buttonLarge),
                SizedBox(height: 4.h),
                Text(
                  content,
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.accountTheme,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: AppTextStyles.captionLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
