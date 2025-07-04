import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:getwidget/getwidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/account_controller.dart';
import '../../../controllers/user_resource_controller.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/user_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class AccountView extends StatefulWidget {
  const AccountView({Key? key}) : super(key: key);

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  AccountController get controller => Get.find<AccountController>();

  // Key để force rebuild FutureBuilder
  Key _futureBuilderKey = UniqueKey();

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
              SizedBox(height: 20.h),
              _buildUserResources(),
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
      key: _futureBuilderKey,
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
          child: Row(
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accountTheme,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: userModel?.avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: userModel!.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surface,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accountTheme),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              gradient: AppDecorations.radialGradientWithColor(AppColors.accountTheme),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Iconsax.profile_circle,
                              size: 40.r,
                              color: AppColors.accountTheme,
                            ),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            gradient: AppDecorations.radialGradientWithColor(AppColors.accountTheme),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Iconsax.profile_circle,
                            size: 40.r,
                            color: AppColors.accountTheme,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userModel?.displayName ?? user.displayName ?? 'Người dùng',
                      style: AppTextStyles.h4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      userModel?.email ?? user.email ?? 'email@example.com',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accountTheme),
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
          icon: Iconsax.task_square,
          title: 'Nhiệm vụ hàng ngày',
          subtitle: 'Hoàn thành nhiệm vụ nhận thưởng',
          onTap: () => Get.toNamed('/daily-quest'),
        ),
        SizedBox(height: 12.h),
        _buildMenuItem(
          icon: Iconsax.medal_star,
          title: 'Thành tựu',
          subtitle: 'Nhiệm vụ tích lũy dài hạn',
          onTap: () => Get.toNamed('/achievement-quest'),
        ),
        SizedBox(height: 12.h),
        _buildMenuItem(
          icon: Iconsax.user_edit,
          title: 'Quản lý tài khoản',
          subtitle: 'Đổi tên và ảnh đại diện',
          onTap: () async {
            final result = await Get.toNamed('/account-management');
            if (result == true) {
              // Force reload FutureBuilder để lấy dữ liệu mới
              setState(() {
                _futureBuilderKey = UniqueKey();
              });
            }
          },
        ),
        SizedBox(height: 12.h),
        _buildMenuItem(
          icon: Iconsax.heart,
          title: 'Anime của tôi',
          subtitle: 'Quản lý danh sách anime',
          onTap: () => Get.toNamed('/anime-list', arguments: {'status': 'saved'}),
        ),
        SizedBox(height: 12.h),
        _buildMenuItem(
          icon: Iconsax.info_circle,
          title: 'Thông tin',
          subtitle: 'Về ứng dụng và nhà phát triển',
          onTap: () => Get.toNamed('/info'),
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

  Widget _buildUserResources() {
    return GetX<UserResourceController>(
      init: UserResourceController(),
      builder: (resourceController) {
        final user = resourceController.currentUser.value;

        if (user == null) {
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
            child: Center(
              child: Text(
                'Đang tải thông tin...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

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
              // Level và EXP
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      gradient: AppDecorations.radialGradientWithColor(AppColors.accountTheme),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.crown,
                          color: AppColors.accountTheme,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Level ${user.level}',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.accountTheme,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Text(
                    user.expDetails,
                    style: AppTextStyles.captionLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // EXP Progress Bar
              Container(
                height: 8.h,
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: user.expProgressPercentage,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accountTheme),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Vàng và Kim cương
              Row(
                children: [
                  Expanded(
                    child: _buildResourceItem(
                      icon: Iconsax.coin,
                      label: 'Vàng',
                      value: user.gold.toString(),
                      color: Colors.amber,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildResourceItem(
                      icon: Iconsax.diamonds,
                      label: 'Kim cương',
                      value: user.diamond.toString(),
                      color: Colors.cyan,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResourceItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTextStyles.captionMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
