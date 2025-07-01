import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/anime_search_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../widgets/anime_card.dart';

class AnimeSearchView extends GetView<AnimeSearchController> {
  const AnimeSearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFiltersRow(),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Tìm kiếm Anime',
        style: AppTextStyles.h4.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Iconsax.arrow_left,
          color: AppColors.textSecondary,
          size: 24.r,
        ),
      ),
      actions: [],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.r),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundPrimary,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.animeTheme.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: controller.searchController,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm anime...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    color: AppColors.animeTheme,
                    size: 20.r,
                  ),
                  suffixIcon: Obx(
                    () => controller.currentQuery.value.isNotEmpty
                        ? IconButton(
                            onPressed: () => controller.clearSearch(),
                            icon: Icon(
                              Iconsax.close_circle,
                              color: AppColors.textSecondary,
                              size: 20.r,
                            ),
                          )
                        : const SizedBox(),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                onSubmitted: (value) => controller.searchAnime(),
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            decoration: BoxDecoration(
              color: AppColors.animeTheme,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              onPressed: () => controller.searchAnime(),
              icon: Icon(
                Iconsax.search_normal,
                color: Colors.white,
                size: 20.r,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: AppColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(
              () => _buildCompactDropdown(
                value: controller.selectedType.value,
                options: controller.typeOptions,
                icon: Iconsax.category,
                onChanged: (value) {
                  controller.selectedType.value = value!;
                  controller.onFilterChanged();
                },
              ),
            ),
            SizedBox(width: 8.w),
            Obx(
              () => _buildCompactDropdown(
                value: controller.selectedStatus.value,
                options: controller.statusOptions,
                icon: Iconsax.status,
                onChanged: (value) {
                  controller.selectedStatus.value = value!;
                  controller.onFilterChanged();
                },
              ),
            ),
            SizedBox(width: 8.w),
            Obx(
              () => _buildCompactDropdown(
                value: controller.selectedRating.value,
                options: controller.ratingOptions,
                icon: Iconsax.shield_tick,
                onChanged: (value) {
                  controller.selectedRating.value = value!;
                  controller.onFilterChanged();
                },
              ),
            ),
            SizedBox(width: 8.w),
            Obx(
              () => _buildCompactDropdown(
                value: controller.selectedScore.value,
                options: controller.scoreOptions,
                icon: Iconsax.star,
                onChanged: (value) {
                  controller.selectedScore.value = value!;
                  controller.onFilterChanged();
                },
              ),
            ),
            SizedBox(width: 8.w),
            // Reset filters button
            Obx(
              () => (controller.selectedType.value != 'all' ||
                      controller.selectedStatus.value != 'all' ||
                      controller.selectedRating.value != 'all' ||
                      controller.selectedScore.value != 'all')
                  ? GestureDetector(
                      onTap: () => controller.resetFilters(),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.textSecondary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.refresh,
                              size: 12.r,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Reset',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
            SizedBox(width: 16.w),
            Obx(
              () => controller.searchResults.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.animeTheme.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.search_status,
                            size: 12.r,
                            color: AppColors.animeTheme,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${controller.searchResults.length} kết quả',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.animeTheme,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactDropdown({
    required String value,
    required List<Map<String, String>> options,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.animeTheme.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.animeTheme.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.r,
            color: AppColors.animeTheme,
          ),
          SizedBox(width: 4.w),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: Icon(
                Iconsax.arrow_down_1,
                size: 12.r,
                color: AppColors.animeTheme,
              ),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.animeTheme,
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
              dropdownColor: AppColors.surface,
              isDense: true,
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Text(
                    option['label']!,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11.sp),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (controller.isLoading.value && controller.searchResults.isEmpty) {
        return _buildLoadingGrid();
      }

      if (controller.error.value.isNotEmpty &&
          controller.searchResults.isEmpty) {
        return _buildErrorWidget();
      }

      if (controller.searchResults.isEmpty &&
          controller.currentQuery.value.isNotEmpty) {
        return _buildEmptyResults();
      }

      if (controller.searchResults.isEmpty) {
        return _buildInitialState();
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent * 0.9) {
            if (!controller.isLoadingMore.value &&
                controller.hasNextPage.value) {
              controller.loadMore();
            }
          }
          return false;
        },
        child: GridView.builder(
          padding: EdgeInsets.all(16.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 16.h,
          ),
          itemCount:
              controller.searchResults.length +
              (controller.isLoadingMore.value ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.searchResults.length) {
              return _buildLoadingCard();
            }
            return AnimeCard(anime: controller.searchResults[index]);
          },
        ),
      );
    });
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_normal,
            size: 80.r,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 24.h),
          Text(
            'Tìm kiếm Anime',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 12.h),
          Text(
            'Nhập tên anime để bắt đầu tìm kiếm',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_status,
            size: 80.r,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 24.h),
          Text(
            'Không tìm thấy kết quả',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 12.h),
          Text(
            'Thử tìm kiếm với từ khóa khác',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surface.withOpacity(0.5),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 64.r, color: AppColors.textSecondary),
          SizedBox(height: 16.h),
          Text(
            'Có lỗi xảy ra',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Text(
            controller.error.value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => controller.searchAnime(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.animeTheme,
              foregroundColor: Colors.white,
            ),
            child: Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
