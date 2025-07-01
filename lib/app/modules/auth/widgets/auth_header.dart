import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class AuthHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            gradient: AppDecorations.primaryGradient,
            borderRadius: AppDecorations.radiusXL,
          ),
          child: Icon(icon, size: 40.sp, color: AppColors.textPrimary),
        ),
        SizedBox(height: 24.h),
        Text(title, style: AppTextStyles.appTitle),
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
