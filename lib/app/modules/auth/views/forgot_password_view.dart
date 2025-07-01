import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/forgot_password_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
          onPressed: controller.goToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              _buildHeader(),
              SizedBox(height: 40.h),
              _buildDescription(),
              SizedBox(height: 32.h),
              _buildForgotPasswordForm(),
              SizedBox(height: 24.h),
              _buildBackToLoginLink(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            gradient: AppDecorations.primaryGradient,
            borderRadius: AppDecorations.radiusXL,
          ),
          child: Icon(
            Iconsax.key,
            size: 40.sp,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Quên mật khẩu?',
          style: AppTextStyles.appTitle,
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      children: [
        Text(
          'Đừng lo lắng! Chúng tôi sẽ gửi hướng dẫn đặt lại mật khẩu đến email của bạn.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Vui lòng nhập địa chỉ email đã đăng ký:',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          _buildEmailField(),
          SizedBox(height: 24.h),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: AppDecorations.inputContainer,
      child: TextFormField(
        controller: controller.emailController,
        validator: controller.validateEmail,
        keyboardType: TextInputType.emailAddress,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Nhập email của bạn',
          hintStyle: AppTextStyles.withColor(AppTextStyles.bodyMedium, AppColors.textTertiary),
          prefixIcon: Icon(
            Iconsax.sms,
            color: AppColors.textTertiary,
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Obx(() {
      if (controller.isEmailSent.value) {
        return Column(
          children: [
            // Thông báo đã gửi email
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: AppDecorations.radiusM,
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mark_email_read,
                    color: AppColors.success,
                    size: 32.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Email đã được gửi!',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Vui lòng kiểm tra hộp thư của bạn',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Nút gửi lại
            GFButton(
              onPressed: controller.isLoading.value
                ? null
                : controller.resendEmail,
              text: controller.isLoading.value ? 'Đang gửi lại...' : 'Gửi lại email',
              size: GFSize.LARGE,
              fullWidthButton: true,
              color: AppColors.buttonSecondary,
              shape: GFButtonShape.pills,
              textStyle: AppTextStyles.buttonLarge,
            ),
          ],
        );
      }

      return GFButton(
        onPressed: controller.isLoading.value
          ? null
          : controller.resetPassword,
        text: controller.isLoading.value ? 'Đang gửi...' : 'Gửi email đặt lại',
        size: GFSize.LARGE,
        fullWidthButton: true,
        color: AppColors.buttonPrimary,
        shape: GFButtonShape.pills,
        textStyle: AppTextStyles.buttonLarge,
      );
    });
  }

  Widget _buildBackToLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Nhớ mật khẩu rồi? ',
          style: AppTextStyles.withColor(AppTextStyles.bodyMedium, AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: controller.goToLogin,
          child: Text(
            'Đăng nhập',
            style: AppTextStyles.withColor(AppTextStyles.buttonMedium, AppColors.primary),
          ),
        ),
      ],
    );
  }
}
