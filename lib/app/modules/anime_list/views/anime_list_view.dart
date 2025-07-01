import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/anime_list_controller.dart';
import '../../../models/anime_watch_status_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';
import '../../../services/streaming_data_service.dart';
import '../../../utils/notification_helper.dart';
import '../../anime/utils/anime_utils.dart';

class AnimeListView extends StatefulWidget {
  const AnimeListView({Key? key}) : super(key: key);

  @override
  State<AnimeListView> createState() => _AnimeListViewState();
}

class _AnimeListViewState extends State<AnimeListView> with SingleTickerProviderStateMixin {
  late AnimeListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AnimeListController>();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: _getInitialTabIndex(),
      child: _buildScaffold(),
    );
  }

  int _getInitialTabIndex() {
    switch (controller.status.value) {
      case AnimeWatchStatus.saved:
        return 0;
      case AnimeWatchStatus.watching:
        return 1;
      case AnimeWatchStatus.completed:
        return 2;
    }
  }

  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDecorations.backgroundGradient,
        ),
        child: TabBarView(
          children: [
            _buildTabContent(AnimeWatchStatus.saved),
            _buildTabContent(AnimeWatchStatus.watching),
            _buildTabContent(AnimeWatchStatus.completed),
          ],
        ),
      ),
    );
  }



  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Anime của tôi',
        style: AppTextStyles.h3.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottom: TabBar(
        isScrollable: true,
        labelColor: AppColors.accountTheme,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.accountTheme,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodySmall,
        onTap: (index) => _onTabChanged(index),
        tabs: [
          Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.heart, size: 16.r),
                SizedBox(height: 2.h),
                Text(
                  'Đã lưu',
                  style: TextStyle(fontSize: 10.sp),
                ),
              ],
            ),
          ),
          Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.play_circle, size: 16.r),
                SizedBox(height: 2.h),
                Text(
                  'Đang xem',
                  style: TextStyle(fontSize: 10.sp),
                ),
              ],
            ),
          ),
          Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.tick_circle, size: 16.r),
                SizedBox(height: 2.h),
                Text(
                  'Hoàn thành',
                  style: TextStyle(fontSize: 10.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onTabChanged(int index) {
    AnimeWatchStatus newStatus;
    switch (index) {
      case 0:
        newStatus = AnimeWatchStatus.saved;
        break;
      case 1:
        newStatus = AnimeWatchStatus.watching;
        break;
      case 2:
        newStatus = AnimeWatchStatus.completed;
        break;
      default:
        newStatus = AnimeWatchStatus.saved;
    }

    controller.changeStatus(newStatus);
  }

  Widget _buildTabContent(AnimeWatchStatus status) {
    return Obx(() {
      // Chỉ hiển thị content cho tab hiện tại
      if (controller.status.value != status) {
        return const SizedBox.shrink();
      }

      if (controller.isLoading.value) {
        return _buildLoadingWidget();
      }

      if (controller.error.value.isNotEmpty) {
        return _buildErrorWidget();
      }

      if (controller.animeList.isEmpty) {
        return _buildEmptyWidget();
      }

      return _buildAnimeList();
    });
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accountTheme),
          ),
          SizedBox(height: 16.h),
          Text(
            'Đang tải danh sách anime...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 64.r,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Có lỗi xảy ra',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.error.value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: controller.loadAnimeList,
              icon: Icon(Iconsax.refresh, size: 20.r),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accountTheme,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(),
              size: 64.r,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              _getEmptyTitle(),
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _getEmptyMessage(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEmptyIcon() {
    switch (controller.status.value) {
      case AnimeWatchStatus.saved:
        return Iconsax.heart;
      case AnimeWatchStatus.watching:
        return Iconsax.play_circle;
      case AnimeWatchStatus.completed:
        return Iconsax.tick_circle;
    }
  }

  String _getEmptyTitle() {
    switch (controller.status.value) {
      case AnimeWatchStatus.saved:
        return 'Chưa có anime nào được lưu';
      case AnimeWatchStatus.watching:
        return 'Chưa có anime nào đang xem';
      case AnimeWatchStatus.completed:
        return 'Chưa hoàn thành anime nào';
    }
  }

  String _getEmptyMessage() {
    switch (controller.status.value) {
      case AnimeWatchStatus.saved:
        return 'Hãy tìm kiếm và lưu những anime yêu thích của bạn';
      case AnimeWatchStatus.watching:
        return 'Bắt đầu xem anime để theo dõi tiến trình';
      case AnimeWatchStatus.completed:
        return 'Xem hết các tập để đánh dấu hoàn thành';
    }
  }

  Widget _buildAnimeList() {
    return RefreshIndicator(
      onRefresh: controller.loadAnimeList,
      color: AppColors.accountTheme,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.animeList.length,
        itemBuilder: (context, index) {
          final anime = controller.animeList[index];
          return _buildAnimeCard(anime);
        },
      ),
    );
  }

  Widget _buildAnimeCard(AnimeWatchStatusModel anime) {
    final streamingService = StreamingDataService();
    final isAvailable = streamingService.isAnimeAvailable(anime.malId);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      height: 120.h, // Giảm chiều cao để tránh overflow
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.accountTheme.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _onAnimeCardTap(anime, isAvailable),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Poster
              Container(
                width: 60.w,
                height: 88.h, // Giảm chiều cao để fit trong container nhỏ hơn
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: _getImageUrl(anime.images),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => AnimeUtils.buildImagePlaceholder(),
                    errorWidget: (context, url, error) => AnimeUtils.buildImageError(),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Info
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 40.w, bottom: 8.h), // Để chỗ cho nút xóa
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              anime.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          _buildStatusInfo(anime),
                        ],
                      ),
                    ),
                    // Nút xóa ở góc phải dưới
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _onDeletePressed(anime),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Iconsax.trash,
                            color: AppColors.error,
                            size: 14.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusInfo(AnimeWatchStatusModel anime) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: _getStatusColor(anime.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: _getStatusColor(anime.status).withOpacity(0.3),
            ),
          ),
          child: Text(
            anime.status.displayName,
            style: AppTextStyles.bodySmall.copyWith(
              color: _getStatusColor(anime.status),
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
          ),
        ),
        if (anime.status == AnimeWatchStatus.watching || anime.status == AnimeWatchStatus.completed) ...[
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              '${anime.watchedEpisodes.length}/${anime.totalEpisodes ?? '?'} tập',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(AnimeWatchStatus status) {
    switch (status) {
      case AnimeWatchStatus.saved:
        return AppColors.accountTheme;
      case AnimeWatchStatus.watching:
        return AppColors.animeTheme;
      case AnimeWatchStatus.completed:
        return AppColors.success;
    }
  }



  void _onAnimeCardTap(AnimeWatchStatusModel anime, bool isAvailable) {
    if (isAvailable) {
      _onWatchPressed(anime);
    } else {
      NotificationHelper.showWarning(
        title: 'Thông báo',
        message: 'Anime này hiện không có sẵn để xem',
      );
    }
  }

  void _onWatchPressed(AnimeWatchStatusModel anime) {
    final streamingService = StreamingDataService();
    final nguoncUrl = streamingService.getNguoncUrl(anime.malId);

    if (nguoncUrl != null) {
      Get.toNamed(
        '/anime-watch',
        arguments: {
          'nguoncUrl': nguoncUrl,
          'animeTitle': anime.title,
          'malId': anime.malId,
        },
      );
    } else {
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không tìm thấy link xem cho anime này',
      );
    }
  }

  void _onDeletePressed(AnimeWatchStatusModel anime) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.warning_2,
              color: AppColors.error,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            Text(
              'Xóa anime',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc muốn xóa "${anime.title}" khỏi danh sách?\n\nHành động này không thể hoàn tác.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Hủy',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAnime(anime);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Xóa',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Lấy URL hình ảnh từ images map một cách an toàn
  String _getImageUrl(Map<String, dynamic> images) {
    try {
      // Cấu trúc từ AnimeImages.toJson(): {'jpg': String, 'webp': String}
      if (images['jpg'] != null && images['jpg'] is String) {
        return images['jpg'] as String;
      }

      if (images['webp'] != null && images['webp'] is String) {
        return images['webp'] as String;
      }

      // Fallback cho cấu trúc phức tạp (từ API gốc)
      if (images['jpg'] != null && images['jpg'] is Map) {
        final jpgMap = images['jpg'] as Map<String, dynamic>;
        if (jpgMap['image_url'] != null) {
          return jpgMap['image_url'] as String;
        }
      }

      if (images['webp'] != null && images['webp'] is Map) {
        final webpMap = images['webp'] as Map<String, dynamic>;
        if (webpMap['image_url'] != null) {
          return webpMap['image_url'] as String;
        }
      }

      return '';
    } catch (e) {
      print('❌ Error getting image URL: $e');
      print('   📊 Images data: $images');
      return '';
    }
  }
}
