import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/anime_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/anime_model.dart';

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
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.9) {
            if (!controller.isLoadingMore.value && controller.hasNextPage.value) {
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
            return _buildAnimeCard(controller.animeList[index]);
          },
        ),
      );
    });
  }

  Widget _buildAnimeCard(AnimeModel anime) {
    return GestureDetector(
      onTap: () => _showAnimeDetails(anime),
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
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) => _buildImageError(),
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
                          anime.members != null ? _formatNumber(anime.members!) : '?',
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
                          anime.episodes != null ? '${anime.episodes} tập' : '? tập',
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Icon(Iconsax.image, color: AppColors.textSecondary, size: 32.r),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Icon(
          Iconsax.warning_2,
          color: AppColors.textSecondary,
          size: 32.r,
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
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



  void _showAnimeDetails(AnimeModel anime) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
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
                              _buildImagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              _buildImageError(),
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
                                    ' (${_formatNumber(anime.scoredBy!)} votes)',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 8.h),
                          ],
                          _buildInfoRow('Loại', anime.type),
                          if (anime.episodes != null)
                            _buildInfoRow('Số tập', '${anime.episodes}'),
                          _buildInfoRow('Trạng thái', anime.status),
                          if (anime.aired != null)
                            _buildInfoRow('Phát sóng', anime.aired!),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
