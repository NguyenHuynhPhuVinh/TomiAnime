import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/anime_model.dart';
import '../utils/anime_utils.dart';
import 'anime_detail_modal.dart';

class AnimeCard extends StatelessWidget {
  final AnimeModel anime;
  final VoidCallback? onTap;

  const AnimeCard({Key? key, required this.anime, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => AnimeDetailModal.show(anime),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anime poster
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
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
            ),
            // Anime info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(6.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating và popularity
                    Row(
                      children: [
                        Icon(Iconsax.star1, color: Colors.amber, size: 12.r),
                        SizedBox(width: 2.w),
                        Text(
                          anime.score?.toStringAsFixed(1) ?? '?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Iconsax.people,
                          color: AppColors.textSecondary,
                          size: 12.r,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          anime.members != null
                              ? AnimeUtils.formatNumber(anime.members!)
                              : '?',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    // Title
                    Text(
                      anime.title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    // Type và episodes
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.animeTheme.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                          child: Text(
                            anime.type,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.animeTheme,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          anime.episodes != null
                              ? '${anime.episodes} tập'
                              : '? tập',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
