import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:getwidget/getwidget.dart';
import '../controllers/account_controller.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/user_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.profile_circle,
              color: AppColors.accountTheme,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            Text('Player Profile', style: AppTextStyles.h5),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: AppDecorations.appBarWithThemeColor(AppColors.accountTheme),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDecorations.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildUserProfile(),
              SizedBox(height: 30.h),
              _buildMenuItems(),
              SizedBox(height: 30.h),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    final authService = AuthService.instance;
    final firestoreService = FirestoreService.instance;
    final user = authService.currentUser;

    if (user == null) {
      return Container(
        padding: EdgeInsets.all(20.w),
        child: Text(
          'Chưa đăng nhập',
          style: AppTextStyles.bodyLarge,
        ),
      );
    }

    return FutureBuilder<UserModel?>(
      future: firestoreService.getUser(user.uid),
      builder: (context, snapshot) {
        final userModel = snapshot.data;

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
                  gradient: AppDecorations.radialGradientWithColor(AppColors.accountTheme),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.profile_circle,
                  size: 60.r,
                  color: AppColors.accountTheme,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                userModel?.displayName ?? user.displayName ?? 'Người dùng',
                style: AppTextStyles.h4,
              ),
              SizedBox(height: 8.h),
              Text(
                userModel?.email ?? user.email ?? 'email@example.com',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accountTheme),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Iconsax.setting_2,
          title: 'Cài đặt',
          subtitle: 'Tùy chỉnh ứng dụng',
          onTap: () {
            Get.snackbar(
              'Thông báo',
              'Tính năng đang phát triển',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        SizedBox(height: 12.h),
        _buildMenuItem(
          icon: Iconsax.heart,
          title: 'Yêu thích',
          subtitle: 'Anime đã lưu',
          onTap: () {
            Get.snackbar(
              'Thông báo',
              'Tính năng đang phát triển',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        SizedBox(height: 12.h),
        _buildMenuItem(
          icon: Iconsax.info_circle,
          title: 'Về ứng dụng',
          subtitle: 'Thông tin phiên bản',
          onTap: () {
            Get.snackbar(
              'TomiAnime',
              'Phiên bản 1.0.0\nPhát triển bởi TomiSakae',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              decoration: AppDecorations.iconContainerWithColor(AppColors.accountTheme),
              child: Icon(
                icon,
                color: AppColors.accountTheme,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.buttonLarge,
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
            Icon(
              Iconsax.arrow_right_3,
              color: AppColors.textTertiary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    final authService = AuthService.instance;

    return GFButton(
      onPressed: () async {
        Get.dialog(
          AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              'Đăng xuất',
              style: AppTextStyles.h4,
            ),
            content: Text(
              'Bạn có chắc chắn muốn đăng xuất?',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Hủy', style: AppTextStyles.buttonMedium),
              ),
              TextButton(
                onPressed: () async {
                  Get.back();
                  await authService.signOut();
                  Get.offAllNamed('/login');
                },
                child: Text(
                  'Đăng xuất',
                  style: AppTextStyles.withColor(AppTextStyles.buttonMedium, AppColors.error),
                ),
              ),
            ],
          ),
        );
      },
      text: 'Đăng xuất',
      size: GFSize.LARGE,
      fullWidthButton: true,
      color: AppColors.error,
      shape: GFButtonShape.pills,
      icon: Icon(
        Iconsax.logout,
        color: AppColors.textPrimary,
        size: 20.sp,
      ),
      textStyle: AppTextStyles.buttonLarge,
    );
  }
}
