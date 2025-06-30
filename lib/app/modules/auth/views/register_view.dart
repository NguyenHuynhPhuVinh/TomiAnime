import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: Colors.white,
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
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Iconsax.user_add,
            size: 40.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Tạo tài khoản',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Tham gia cộng đồng TomiAnime',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[400],
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
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF2D3561)),
      ),
      child: TextFormField(
        controller: controller.emailController,
        validator: controller.validateEmail,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(
            Iconsax.sms,
            color: Colors.grey[500],
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
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF2D3561)),
      ),
      child: Obx(() => TextFormField(
        controller: controller.passwordController,
        validator: controller.validatePassword,
        obscureText: !controller.isPasswordVisible.value,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: 'Mật khẩu',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(
            Iconsax.lock,
            color: Colors.grey[500],
            size: 20.sp,
          ),
          suffixIcon: GestureDetector(
            onTap: controller.togglePasswordVisibility,
            child: Icon(
              controller.isPasswordVisible.value 
                ? Iconsax.eye 
                : Iconsax.eye_slash,
              color: Colors.grey[500],
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
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF2D3561)),
      ),
      child: Obx(() => TextFormField(
        controller: controller.confirmPasswordController,
        validator: controller.validateConfirmPassword,
        obscureText: !controller.isConfirmPasswordVisible.value,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: 'Xác nhận mật khẩu',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(
            Iconsax.lock,
            color: Colors.grey[500],
            size: 20.sp,
          ),
          suffixIcon: GestureDetector(
            onTap: controller.toggleConfirmPasswordVisibility,
            child: Icon(
              controller.isConfirmPasswordVisible.value 
                ? Iconsax.eye 
                : Iconsax.eye_slash,
              color: Colors.grey[500],
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
      color: const Color(0xFF6C5CE7),
      shape: GFButtonShape.pills,
      textStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    ));
  }

  Widget _buildGoogleSignInButton() {
    return Obx(() => Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                    ),
                  )
                else
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                SizedBox(width: 12.w),
                Text(
                  controller.isGoogleLoading.value
                    ? 'Đang đăng nhập...'
                    : 'Đăng ký với Google',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
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
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14.sp,
          ),
        ),
        GestureDetector(
          onTap: controller.goToLogin,
          child: Text(
            'Đăng nhập',
            style: TextStyle(
              color: const Color(0xFF6C5CE7),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
