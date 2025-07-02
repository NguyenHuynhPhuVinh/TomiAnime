import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:getwidget/getwidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/account_management_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class AccountManagementView extends GetView<AccountManagementController> {
  const AccountManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.user_edit,
              color: AppColors.accountTheme,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            Text('Quản lý tài khoản', style: AppTextStyles.h5),
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
          decoration: AppDecorations.appBarWithThemeColor(AppColors.accountTheme),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDecorations.backgroundGradient,
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accountTheme),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildAvatarSection(),
                  SizedBox(height: 30.h),
                  _buildDisplayNameField(),
                  SizedBox(height: 30.h),
                  _buildEmailField(),
                  SizedBox(height: 40.h),
                  _buildUpdateButton(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAvatarSection() {
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
          Text(
            'Ảnh đại diện',
            style: AppTextStyles.h4,
          ),
          SizedBox(height: 16.h),
          Obx(() {
            String? avatarUrl;
            
            if (controller.selectedAvatarUrl.value.isNotEmpty) {
              avatarUrl = controller.selectedAvatarUrl.value;
            } else if (controller.currentUser.value?.avatarUrl != null) {
              avatarUrl = controller.currentUser.value!.avatarUrl;
            }

            return GestureDetector(
              onTap: controller.selectAnimeCharacterAvatar,
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accountTheme,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl,
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
                            color: AppColors.surface,
                            child: Icon(
                              Iconsax.profile_circle,
                              size: 60.r,
                              color: AppColors.accountTheme,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.surface,
                          child: Icon(
                            Iconsax.profile_circle,
                            size: 60.r,
                            color: AppColors.accountTheme,
                          ),
                        ),
                ),
              ),
            );
          }),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GFButton(
                onPressed: controller.selectAnimeCharacterAvatar,
                text: 'Chọn Avatar',
                size: GFSize.SMALL,
                color: AppColors.accountTheme,
                shape: GFButtonShape.pills,
                icon: Icon(
                  Iconsax.search_normal,
                  color: AppColors.textPrimary,
                  size: 16.sp,
                ),
                textStyle: AppTextStyles.buttonSmall,
              ),
              SizedBox(width: 12.w),
              Obx(() {
                if (controller.selectedAvatarUrl.value.isNotEmpty || 
                    controller.currentUser.value?.avatarUrl != null) {
                  return GFButton(
                    onPressed: controller.clearSelectedAvatar,
                    text: 'Xóa',
                    size: GFSize.SMALL,
                    color: AppColors.error,
                    shape: GFButtonShape.pills,
                    icon: Icon(
                      Iconsax.trash,
                      color: AppColors.textPrimary,
                      size: 16.sp,
                    ),
                    textStyle: AppTextStyles.buttonSmall,
                  );
                }
                return const SizedBox();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayNameField() {
    return TextFormField(
      controller: controller.displayNameController,
      style: AppTextStyles.bodyLarge,
      validator: controller.validateDisplayName,
      decoration: InputDecoration(
        labelText: 'Tên hiển thị',
        hintText: 'Nhập tên hiển thị của bạn',
        prefixIcon: Icon(
          Iconsax.user,
          color: AppColors.accountTheme,
          size: 20.sp,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.accountTheme,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppDecorations.radiusM,
          borderSide: BorderSide(
            color: AppColors.accountTheme.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDecorations.radiusM,
          borderSide: BorderSide(
            color: AppColors.accountTheme.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDecorations.radiusM,
          borderSide: BorderSide(
            color: AppColors.accountTheme,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDecorations.radiusM,
          borderSide: BorderSide(
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Obx(() {
      final email = controller.currentUser.value?.email ?? '';
      return TextFormField(
        initialValue: email,
        enabled: false,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textSecondary,
        ),
        decoration: InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(
            Iconsax.sms,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: AppColors.surface.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: AppDecorations.radiusM,
            borderSide: BorderSide(
              color: AppColors.textTertiary.withOpacity(0.3),
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: AppDecorations.radiusM,
            borderSide: BorderSide(
              color: AppColors.textTertiary.withOpacity(0.3),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildUpdateButton() {
    return Obx(() => GFButton(
      onPressed: controller.isUpdating.value ? null : controller.updateAccount,
      text: controller.isUpdating.value ? 'Đang cập nhật...' : 'Cập nhật thông tin',
      size: GFSize.LARGE,
      fullWidthButton: true,
      color: AppColors.accountTheme,
      shape: GFButtonShape.pills,
      icon: Icon(
        controller.isUpdating.value ? Iconsax.refresh : Iconsax.tick_circle,
        color: AppColors.textPrimary,
        size: 20.sp,
      ),
      textStyle: AppTextStyles.buttonLarge,
    ));
  }
}
