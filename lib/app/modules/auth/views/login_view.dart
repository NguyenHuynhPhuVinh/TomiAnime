import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/login_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_email_field.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_google_button.dart';
import '../widgets/auth_navigation_link.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 60.h),
              _buildHeader(),
              SizedBox(height: 40.h),
              _buildLoginForm(),
              SizedBox(height: 24.h),
              _buildGoogleSignInButton(),
              SizedBox(height: 24.h),
              _buildForgotPassword(),
              SizedBox(height: 16.h),
              _buildRegisterLink(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const AuthHeader(
      icon: Iconsax.user,
      title: 'TomiAnime',
      subtitle: 'Chào mừng trở lại!',
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          _buildEmailField(),
          SizedBox(height: 16.h),
          _buildPasswordField(),
          SizedBox(height: 24.h),
          _buildLoginButton(),
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

  Widget _buildLoginButton() {
    return Obx(
      () => GFButton(
        onPressed: controller.isLoginLoading.value
            ? null
            : controller.signInWithEmailAndPassword,
        text: controller.isLoginLoading.value
            ? 'Đang đăng nhập...'
            : 'Đăng nhập',
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
      text: 'Đăng nhập với Google',
    );
  }

  Widget _buildForgotPassword() {
    return AuthSimpleLink(
      text: 'Quên mật khẩu?',
      onTap: controller.goToForgotPassword,
    );
  }

  Widget _buildRegisterLink() {
    return AuthNavigationLink(
      prefixText: 'Chưa có tài khoản? ',
      linkText: 'Đăng ký ngay',
      onTap: controller.goToRegister,
    );
  }
}
