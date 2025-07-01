import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/register_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_email_field.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_google_button.dart';
import '../widgets/auth_navigation_link.dart';

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
    return const AuthHeader(
      icon: Iconsax.user_add,
      title: 'Tạo tài khoản',
      subtitle: 'Tham gia cộng đồng TomiAnime',
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
    return AuthEmailField(
      controller: controller.emailController,
      validator: controller.validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return AuthPasswordField(
      controller: controller.passwordController,
      validator: controller.validatePassword,
      isPasswordVisible: controller.isPasswordVisible,
      onToggleVisibility: controller.togglePasswordVisibility,
    );
  }

  Widget _buildConfirmPasswordField() {
    return AuthPasswordField(
      controller: controller.confirmPasswordController,
      validator: controller.validateConfirmPassword,
      hintText: 'Xác nhận mật khẩu',
      isPasswordVisible: controller.isConfirmPasswordVisible,
      onToggleVisibility: controller.toggleConfirmPasswordVisibility,
    );
  }

  Widget _buildRegisterButton() {
    return Obx(
      () => GFButton(
        onPressed: controller.isRegisterLoading.value
            ? null
            : controller.signUpWithEmailAndPassword,
        text: controller.isRegisterLoading.value
            ? 'Đang tạo tài khoản...'
            : 'Tạo tài khoản',
        size: GFSize.LARGE,
        fullWidthButton: true,
        color: AppColors.buttonPrimary,
        shape: GFButtonShape.pills,
        textStyle: AppTextStyles.buttonLarge,
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return AuthGoogleButton(
      onPressed: controller.signInWithGoogle,
      isLoading: controller.isGoogleLoading,
      text: 'Đăng ký với Google',
    );
  }

  Widget _buildLoginLink() {
    return AuthNavigationLink(
      prefixText: 'Đã có tài khoản? ',
      linkText: 'Đăng nhập',
      onTap: controller.goToLogin,
    );
  }
}
