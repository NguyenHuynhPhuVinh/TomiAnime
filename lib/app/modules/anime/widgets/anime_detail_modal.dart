import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/anime_model.dart';
import '../utils/anime_utils.dart';

class AnimeDetailModal {
  static void show(AnimeModel anime) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.all(20.r),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Anime info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poster
                    Container(
                      width: 120.w,
                      height: 160.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: anime.images.jpg ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              AnimeUtils.buildImagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              AnimeUtils.buildImageError(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anime.title,
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (anime.titleEnglish != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              anime.titleEnglish!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          SizedBox(height: 12.h),
                          if (anime.score != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Iconsax.star1,
                                  color: Colors.amber,
                                  size: 16.r,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${anime.score}/10',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (anime.scoredBy != null) ...[
                                  Text(
                                    ' (${AnimeUtils.formatNumber(anime.scoredBy!)} votes)',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 8.h),
                          ],
                          AnimeUtils.buildInfoRow('Loại', anime.type),
                          if (anime.episodes != null)
                            AnimeUtils.buildInfoRow(
                              'Số tập',
                              '${anime.episodes}',
                            ),
                          AnimeUtils.buildInfoRow('Trạng thái', anime.status),
                          if (anime.aired != null)
                            AnimeUtils.buildInfoRow('Phát sóng', anime.aired!),
                        ],
                      ),
                    ),
                  ],
                ),
                if (anime.genres.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Text(
                    'Thể loại',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: anime.genres
                        .map(
                          (genre) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.animeTheme.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.animeTheme.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              genre,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.animeTheme,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (anime.synopsis != null) ...[
                  SizedBox(height: 20.h),
                  Text(
                    'Tóm tắt',
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    anime.synopsis!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
