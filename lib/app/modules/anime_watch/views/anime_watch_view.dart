import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/anime_watch_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/anime_watch_status_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/auth_service.dart';

class AnimeWatchView extends GetView<AnimeWatchController> {
  const AnimeWatchView({Key? key}) : super(key: key);

  // Observable để trigger reload watch status
  static final RxInt _reloadTrigger = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingWidget();
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorWidget();
        }

        if (controller.movie.value == null) {
          return _buildEmptyWidget();
        }

        return _buildContent();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
        onPressed: () => Get.back(),
      ),
      title: Obx(
        () => Text(
          controller.movie.value?.name ?? controller.animeTitle,
          style: AppTextStyles.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Iconsax.refresh, color: AppColors.textPrimary),
          onPressed: () => controller.refresh(),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.animeTheme),
          SizedBox(height: 16.h),
          Text(
            'Đang tải thông tin anime...',
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
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 64.r, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Có lỗi xảy ra',
              style: AppTextStyles.h5.copyWith(
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
              onPressed: () => controller.refresh(),
              icon: Icon(Iconsax.refresh, size: 20.r),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.animeTheme,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.video_slash, size: 64.r, color: AppColors.textSecondary),
          SizedBox(height: 16.h),
          Text(
            'Không tìm thấy thông tin anime',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final movie = controller.movie.value!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMovieInfo(movie),
          SizedBox(height: 16.h),
          _buildWatchStatus(),
          SizedBox(height: 16.h),
          _buildDescription(movie),
          SizedBox(height: 24.h),
          _buildEpisodesList(),
        ],
      ),
    );
  }

  /// Widget hiển thị trạng thái xem anime
  Widget _buildWatchStatus() {
    return Obx(() {
      // Lắng nghe _reloadTrigger để trigger rebuild
      _reloadTrigger.value;

      return FutureBuilder<AnimeWatchStatusModel?>(
        future: _getWatchStatus(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final watchStatus = snapshot.data!;
          final totalEpisodes = controller.allEpisodes.length;
          final watchedCount = watchStatus.watchedEpisodes.length;
          final progress = totalEpisodes > 0
              ? watchedCount / totalEpisodes
              : 0.0;

          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _getStatusColor(watchStatus.status).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(watchStatus.status),
                      color: _getStatusColor(watchStatus.status),
                      size: 20.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      watchStatus.status.displayName,
                      style: AppTextStyles.h5.copyWith(
                        color: _getStatusColor(watchStatus.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$watchedCount/$totalEpisodes tập',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStatusColor(watchStatus.status),
                    ),
                    minHeight: 6.h,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% hoàn thành',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Future<AnimeWatchStatusModel?> _getWatchStatus() async {
    final authService = AuthService.instance;
    final user = authService.currentUser;
    if (user == null) return null;

    final firestoreService = FirestoreService.instance;
    return await firestoreService.getAnimeWatchStatus(
      user.uid,
      controller.malId,
    );
  }

  IconData _getStatusIcon(AnimeWatchStatus status) {
    switch (status) {
      case AnimeWatchStatus.saved:
        return Iconsax.heart5;
      case AnimeWatchStatus.watching:
        return Iconsax.play_circle;
      case AnimeWatchStatus.completed:
        return Iconsax.tick_circle;
    }
  }

  Color _getStatusColor(AnimeWatchStatus status) {
    switch (status) {
      case AnimeWatchStatus.saved:
        return AppColors.animeTheme;
      case AnimeWatchStatus.watching:
        return AppColors.animeTheme;
      case AnimeWatchStatus.completed:
        return AppColors.success;
    }
  }

  Widget _buildMovieInfo(movie) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poster
        Container(
          width: 100.w,
          height: 140.h,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: movie.posterUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surface,
                child: Icon(
                  Iconsax.image,
                  color: AppColors.textSecondary,
                  size: 32.r,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surface,
                child: Icon(
                  Iconsax.warning_2,
                  color: AppColors.error,
                  size: 32.r,
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 16.w),

        // Movie details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.name,
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (movie.originalName.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  movie.originalName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              SizedBox(height: 8.h),

              _buildInfoRow('Tổng số tập', '${movie.totalEpisodes}'),
              _buildInfoRow('Trạng thái', movie.currentEpisode),
              _buildInfoRow('Thời lượng', movie.time),
              _buildInfoRow('Chất lượng', movie.quality),
              _buildInfoRow('Ngôn ngữ', movie.language),
            ],
          ),
        ),
      ],
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

  Widget _buildDescription(movie) {
    if (movie.description == null || movie.description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mô tả',
          style: AppTextStyles.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            movie.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodesList() {
    final episodes = controller.allEpisodes;

    if (episodes.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            'Không có tập phim nào',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Danh sách tập',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.animeTheme.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${episodes.length} tập',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.animeTheme,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Episodes grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemCount: episodes.length,
          itemBuilder: (context, index) {
            final episode = episodes[index];

            return Obx(() {
              // Lắng nghe reload trigger
              _reloadTrigger.value;

              return FutureBuilder<bool>(
                future: _isEpisodeWatched(index),
                builder: (context, snapshot) {
                  final isWatched = snapshot.data ?? false;

                  return GestureDetector(
                    onTap: () => _onEpisodeTap(episode, index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isWatched
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isWatched
                              ? AppColors.success
                              : AppColors.surface,
                          width: 1.w,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              episode.name,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isWatched
                                    ? AppColors.success
                                    : AppColors.textPrimary,
                                fontWeight: isWatched
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (isWatched)
                            Positioned(
                              top: 4.h,
                              right: 4.w,
                              child: Icon(
                                Iconsax.tick_circle,
                                color: AppColors.success,
                                size: 12.r,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            });
          },
        ),
      ],
    );
  }

  Future<bool> _isEpisodeWatched(int episodeIndex) async {
    final watchStatus = await _getWatchStatus();
    if (watchStatus == null) return false;
    return watchStatus.watchedEpisodes.contains(episodeIndex);
  }

  /// Xử lý khi tap vào tập phim
  void _onEpisodeTap(episode, int index) async {
    // Cập nhật selected episode
    controller.selectEpisode(index);

    print('🎬 Navigating to video player:');
    print('   📺 Episode: ${episode.name}');
    print('   🔗 Embed URL: ${episode.embed}');

    // Navigate đến video player screen và lắng nghe kết quả
    final result = await Get.toNamed(
      '/video-player',
      arguments: {
        'embedUrl': episode.embed,
        'episodeName': episode.name,
        'animeTitle': controller.animeTitle,
        'episodeIndex': index,
        'totalEpisodes': controller.allEpisodes.length,
      },
    );

    // Kiểm tra nếu cần reload trạng thái
    if (result != null && result is Map<String, dynamic>) {
      final shouldReload = result['shouldReload'] as bool? ?? false;
      if (shouldReload) {
        print('🔄 Reloading watch status after returning from video player');
        _reloadWatchStatus();
      }
    }
  }

  /// Reload trạng thái xem anime
  void _reloadWatchStatus() {
    // Trigger rebuild bằng cách thay đổi reactive variable
    _reloadTrigger.value++;
    print('🔄 Watch status reload triggered (${_reloadTrigger.value})');
  }
}
