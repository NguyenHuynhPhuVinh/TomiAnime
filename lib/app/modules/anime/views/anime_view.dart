import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/anime_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/anime_card.dart';

class AnimeView extends GetView<AnimeController> {
  const AnimeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSeasonTabs(),
          _buildFiltersRow(),
          Expanded(child: _buildAnimeGrid()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'TomiAnime',
        style: AppTextStyles.h4.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColors.animeTheme.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Iconsax.play, color: AppColors.animeTheme, size: 20.r),
      ),
      actions: [
        IconButton(
          onPressed: () => _navigateToSearch(),
          icon: Icon(
            Iconsax.search_normal,
            color: AppColors.textSecondary,
            size: 24.r,
          ),
        ),
        IconButton(
          onPressed: () => _showYearPicker(),
          icon: Icon(
            Iconsax.calendar,
            color: AppColors.textSecondary,
            size: 24.r,
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonTabs() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: controller.tabController,
        tabs: [
          Tab(text: 'Đông'),
          Tab(text: 'Xuân'),
          Tab(text: 'Hè'),
          Tab(text: 'Thu'),
        ],
        labelColor: AppColors.animeTheme,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.animeTheme,
        indicatorWeight: 3.h,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodySmall,
        isScrollable: false,
        labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: AppColors.surface,
      child: Row(
        children: [
          Obx(() => _buildCompactTypeDropdown()),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.animeTheme.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Obx(
              () => Text(
                '${controller.selectedYear.value}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.animeTheme,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => controller.refresh(),
            icon: Icon(
              Iconsax.refresh,
              color: AppColors.textSecondary,
              size: 18.r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.animeTheme.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.animeTheme.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedType.value,
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
          items: controller.typeOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(
                option['label']!,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11.sp),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.onTypeChanged(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAnimeGrid() {
    return Obx(() {
      if (controller.isLoading.value && controller.animeList.isEmpty) {
        return _buildLoadingGrid();
      }

      if (controller.error.value.isNotEmpty && controller.animeList.isEmpty) {
        return _buildErrorWidget();
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // Chỉ load more khi scroll đến gần cuối (90% của scroll)
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
              controller.animeList.length +
              (controller.isLoadingMore.value ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.animeList.length) {
              return _buildLoadingCard();
            }
            return AnimeCard(anime: controller.animeList[index]);
          },
        ),
      );
    });
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
            onPressed: () => controller.refresh(),
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

  void _navigateToSearch() {
    Get.toNamed('/anime-search');
  }

  void _showYearPicker() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Chọn năm',
          style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
        ),
        content: SizedBox(
          width: 300.w,
          height: 300.h,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
            ),
            itemCount: DateTime.now().year - 2000 + 1,
            itemBuilder: (context, index) {
              final year = DateTime.now().year - index;
              return Obx(
                () => GestureDetector(
                  onTap: () {
                    controller.onYearChanged(year);
                    Get.back();
                  },
                  child: Container(
                    margin: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: controller.selectedYear.value == year
                          ? AppColors.animeTheme
                          : AppColors.backgroundPrimary,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: controller.selectedYear.value == year
                            ? AppColors.animeTheme
                            : AppColors.textSecondary.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        year.toString(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: controller.selectedYear.value == year
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Đóng',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.animeTheme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
