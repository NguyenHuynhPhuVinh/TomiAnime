import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class AuthPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final RxBool isPasswordVisible;
  final VoidCallback onToggleVisibility;

  const AuthPasswordField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText = 'Mật khẩu',
    required this.isPasswordVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.inputContainer,
      child: Obx(() => TextFormField(
        controller: controller,
        validator: validator,
        obscureText: !isPasswordVisible.value,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.withColor(AppTextStyles.bodyMedium, AppColors.textTertiary),
          prefixIcon: Icon(
            Iconsax.lock,
            color: AppColors.textTertiary,
            size: 20.sp,
          ),
          suffixIcon: GestureDetector(
            onTap: onToggleVisibility,
            child: Icon(
              isPasswordVisible.value
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
}
