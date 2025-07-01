import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/forgot_password_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_email_field.dart';
import '../widgets/auth_navigation_link.dart';

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
    return const AuthHeader(
      icon: Iconsax.key,
      title: 'Quên mật khẩu?',
      subtitle: '',
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
    return AuthEmailField(
      controller: controller.emailController,
      validator: controller.validateEmail,
      hintText: 'Nhập email của bạn',
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
    return AuthNavigationLink(
      prefixText: 'Nhớ mật khẩu rồi? ',
      linkText: 'Đăng nhập',
      onTap: controller.goToLogin,
    );
  }
}
