import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/register_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

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
              SizedBox(height: 20.h),
              _buildHeader(),
              SizedBox(height: 40.h),
              _buildRegisterForm(),
              SizedBox(height: 24.h),
              _buildGoogleSignInButton(),
              SizedBox(height: 24.h),
              _buildLoginLink(),
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
            Iconsax.user_add,
            size: 40.sp,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Tạo tài khoản',
          style: AppTextStyles.appTitle,
        ),
        SizedBox(height: 8.h),
        Text(
          'Tham gia cộng đồng TomiAnime',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          _buildEmailField(),
          SizedBox(height: 16.h),
          _buildPasswordField(),
          SizedBox(height: 16.h),
          _buildConfirmPasswordField(),
          SizedBox(height: 24.h),
          _buildRegisterButton(),
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
          hintText: 'Email',
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

  Widget _buildPasswordField() {
    return Container(
      decoration: AppDecorations.inputContainer,
      child: Obx(() => TextFormField(
        controller: controller.passwordController,
        validator: controller.validatePassword,
        obscureText: !controller.isPasswordVisible.value,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Mật khẩu',
          hintStyle: AppTextStyles.withColor(AppTextStyles.bodyMedium, AppColors.textTertiary),
          prefixIcon: Icon(
            Iconsax.lock,
            color: AppColors.textTertiary,
            size: 20.sp,
          ),
          suffixIcon: GestureDetector(
            onTap: controller.togglePasswordVisibility,
            child: Icon(
              controller.isPasswordVisible.value
                ? Iconsax.eye
                : Iconsax.eye_slash,
              color: AppColors.textTertiary,
              size: 20.sp,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      )),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: AppDecorations.inputContainer,
      child: Obx(() => TextFormField(
        controller: controller.confirmPasswordController,
        validator: controller.validateConfirmPassword,
        obscureText: !controller.isConfirmPasswordVisible.value,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Xác nhận mật khẩu',
          hintStyle: AppTextStyles.withColor(AppTextStyles.bodyMedium, AppColors.textTertiary),
          prefixIcon: Icon(
            Iconsax.lock,
            color: AppColors.textTertiary,
            size: 20.sp,
          ),
          suffixIcon: GestureDetector(
            onTap: controller.toggleConfirmPasswordVisibility,
            child: Icon(
              controller.isConfirmPasswordVisible.value
                ? Iconsax.eye
                : Iconsax.eye_slash,
              color: AppColors.textTertiary,
              size: 20.sp,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      )),
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() => GFButton(
      onPressed: controller.isRegisterLoading.value
        ? null
        : controller.signUpWithEmailAndPassword,
      text: controller.isRegisterLoading.value ? 'Đang tạo tài khoản...' : 'Tạo tài khoản',
      size: GFSize.LARGE,
      fullWidthButton: true,
      color: AppColors.buttonPrimary,
      shape: GFButtonShape.pills,
      textStyle: AppTextStyles.buttonLarge,
    ));
  }

  Widget _buildGoogleSignInButton() {
    return Obx(() => Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: AppDecorations.radiusXL,
        boxShadow: AppDecorations.shadowLight,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.isGoogleLoading.value
            ? null
            : controller.signInWithGoogle,
          borderRadius: BorderRadius.circular(25.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.isGoogleLoading.value)
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textTertiary),
                    ),
                  )
                else
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: AppDecorations.radiusXS,
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: AppTextStyles.withSize(AppTextStyles.buttonSmall, 12),
                      ),
                    ),
                  ),
                SizedBox(width: 12.w),
                Text(
                  controller.isGoogleLoading.value
                    ? 'Đang đăng nhập...'
                    : 'Đăng ký với Google',
                  style: AppTextStyles.withColor(AppTextStyles.buttonLarge, AppColors.backgroundPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
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
