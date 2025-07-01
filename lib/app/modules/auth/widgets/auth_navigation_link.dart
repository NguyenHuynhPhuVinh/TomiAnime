import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class AuthNavigationLink extends StatelessWidget {
  final String prefixText;
  final String linkText;
  final VoidCallback onTap;

  const AuthNavigationLink({
    super.key,
    required this.prefixText,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prefixText,
          style: AppTextStyles.withColor(AppTextStyles.bodyMedium, AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: AppTextStyles.withColor(AppTextStyles.buttonMedium, AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class AuthSimpleLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AuthSimpleLink({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AppTextStyles.withColor(AppTextStyles.buttonMedium, AppColors.primary),
      ),
    );
  }
}
