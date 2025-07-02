import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/anime_model.dart';
import '../../../services/streaming_data_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/jikan_api_service.dart';
import '../../../models/anime_watch_status_model.dart';
import '../../../utils/notification_helper.dart';
import '../utils/anime_utils.dart';

class AnimeDetailModal {
  static void show(AnimeModel anime) {
    // Debug log khi mở anime detail
    print('🎬 Opening anime detail:');
    print('   📋 MAL ID: ${anime.malId}');
    print('   🏷️  Title: ${anime.title}');
    print('   🌐 English: ${anime.titleEnglish ?? 'N/A'}');
    print('   🇯🇵 Japanese: ${anime.titleJapanese ?? 'N/A'}');
    print('   📺 Type: ${anime.type}');
    print('   ⭐ Score: ${anime.score ?? 'N/A'}');

    // Kiểm tra streaming availability
    final streamingService = StreamingDataService();
    final isAvailable = streamingService.isAnimeAvailable(anime.malId);
    final nguoncUrl = streamingService.getNguoncUrl(anime.malId);

    print('   🎥 Streaming available: $isAvailable');
    if (isAvailable && nguoncUrl != null) {
      print('   🔗 Nguonc URL: $nguoncUrl');
    }
    print('   ─────────────────────────────────');

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
        builder: (context, scrollController) => _AnimeDetailContent(
          anime: anime,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _AnimeDetailContent extends StatefulWidget {
  final AnimeModel anime;
  final ScrollController scrollController;

  const _AnimeDetailContent({
    Key? key,
    required this.anime,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<_AnimeDetailContent> createState() => _AnimeDetailContentState();
}

class _AnimeDetailContentState extends State<_AnimeDetailContent> {
  final Rxn<AnimeWatchStatusModel> watchStatus = Rxn<AnimeWatchStatusModel>();
  final RxBool isLoadingStatus = false.obs;
  final Rxn<AnimeRelationsResponse> animeRelations = Rxn<AnimeRelationsResponse>();
  final RxBool isLoadingRelations = false.obs;
  final JikanApiService _apiService = JikanApiService();

  @override
  void initState() {
    super.initState();
    _loadWatchStatus();
    _loadAnimeRelations();
  }

  /// Tải trạng thái xem anime
  Future<void> _loadWatchStatus() async {
    final authService = AuthService.instance;
    final user = authService.currentUser!; // User đã đăng nhập rồi

    final firestoreService = FirestoreService.instance;
    final status = await firestoreService.getAnimeWatchStatus(
      user.uid,
      widget.anime.malId,
    );
    watchStatus.value = status;
  }

  /// Tải anime relations
  Future<void> _loadAnimeRelations() async {
    try {
      isLoadingRelations.value = true;
      final relations = await _apiService.getAnimeRelations(widget.anime.malId);
      animeRelations.value = relations;

      print('🔗 Loaded relations for ${widget.anime.title}:');
      for (final relation in relations.data) {
        print('   ${relation.relation}: ${relation.entry.length} entries');
        for (final entry in relation.entry) {
          if (entry.type == 'anime') {
            print('     - ${entry.name} (MAL ID: ${entry.malId})');
          }
        }
      }
    } catch (e) {
      print('❌ Error loading anime relations: $e');
      // Không hiển thị error cho user vì relations không phải là tính năng quan trọng
    } finally {
      isLoadingRelations.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.all(20.r),
      child: SingleChildScrollView(
        controller: widget.scrollController,
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
                      imageUrl: widget.anime.images.jpg ?? '',
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
                        widget.anime.title,
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.anime.titleEnglish != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          widget.anime.titleEnglish!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      SizedBox(height: 12.h),
                      if (widget.anime.score != null) ...[
                        Row(
                          children: [
                            Icon(
                              Iconsax.star1,
                              color: Colors.amber,
                              size: 16.r,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${widget.anime.score}/10',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.anime.scoredBy != null) ...[
                              Text(
                                ' (${AnimeUtils.formatNumber(widget.anime.scoredBy!)} votes)',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 8.h),
                      ],
                      AnimeUtils.buildInfoRow('Loại', widget.anime.type),
                      if (widget.anime.episodes != null)
                        AnimeUtils.buildInfoRow(
                          'Số tập',
                          '${widget.anime.episodes}',
                        ),
                      AnimeUtils.buildInfoRow(
                        'Trạng thái',
                        widget.anime.status,
                      ),
                      if (widget.anime.aired != null)
                        AnimeUtils.buildInfoRow(
                          'Phát sóng',
                          widget.anime.aired!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.anime.genres.isNotEmpty) ...[
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
                children: widget.anime.genres
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
            // Hiển thị tóm tắt chỉ khi anime không có nút xem
            _buildSynopsisSection(),
            // Nút xem anime và lưu anime
            _buildActionButtons(),
            // Hiển thị anime relations
            _buildRelationsSection(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  /// Widget hiển thị anime relations
  Widget _buildRelationsSection() {
    return Obx(() {
      final relations = animeRelations.value;
      if (relations == null || relations.data.isEmpty) {
        return const SizedBox.shrink();
      }

      // Lọc chỉ lấy anime relations (không lấy manga)
      final filteredAnimeRelations = relations.data.where((relation) {
        return relation.entry.any((entry) => entry.type == 'anime');
      }).toList();

      if (filteredAnimeRelations.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            'Anime liên quan',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          ...filteredAnimeRelations.map((relation) => _buildRelationGroup(relation)),
        ],
      );
    });
  }

  /// Widget hiển thị một nhóm relation
  Widget _buildRelationGroup(AnimeRelation relation) {
    // Lọc chỉ lấy anime entries
    final animeEntries = relation.entry.where((entry) => entry.type == 'anime').toList();

    if (animeEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getRelationDisplayName(relation.relation),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        ...animeEntries.map((entry) => _buildRelationEntry(entry)),
        SizedBox(height: 12.h),
      ],
    );
  }

  /// Widget hiển thị một anime relation entry
  Widget _buildRelationEntry(AnimeRelationEntry entry) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: () => _onRelationTapped(entry),
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.animeTheme.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppColors.animeTheme.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.play_circle,
                color: AppColors.animeTheme,
                size: 20.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  entry.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                color: AppColors.textSecondary,
                size: 16.r,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Lấy tên hiển thị cho relation type
  String _getRelationDisplayName(String relation) {
    switch (relation.toLowerCase()) {
      case 'sequel':
        return 'Mùa kế tiếp';
      case 'prequel':
        return 'Mùa trước';
      case 'side story':
        return 'Câu chuyện phụ';
      case 'alternative version':
        return 'Phiên bản khác';
      case 'alternative setting':
        return 'Bối cảnh khác';
      case 'spin-off':
        return 'Spin-off';
      case 'adaptation':
        return 'Chuyển thể';
      case 'summary':
        return 'Tóm tắt';
      case 'parent story':
        return 'Câu chuyện gốc';
      case 'full story':
        return 'Câu chuyện đầy đủ';
      case 'other':
        return 'Khác';
      default:
        return relation;
    }
  }

  /// Xử lý khi nhấn vào anime relation
  Future<void> _onRelationTapped(AnimeRelationEntry entry) async {
    try {
      // Đóng modal hiện tại
      Get.back();

      // Lấy chi tiết anime từ API
      final animeDetails = await _apiService.getAnimeDetails(entry.malId);

      // Hiển thị modal mới với anime details
      AnimeDetailModal.show(animeDetails);
    } catch (e) {
      print('❌ Error loading related anime details: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể tải thông tin anime này',
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Widget hiển thị tóm tắt (chỉ khi anime không có nút xem)
  Widget _buildSynopsisSection() {
    final streamingService = StreamingDataService();
    final isAvailable = streamingService.isAnimeAvailable(widget.anime.malId);

    // Chỉ hiển thị tóm tắt khi anime không có nút xem
    if (isAvailable || widget.anime.synopsis == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          widget.anime.synopsis!,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Widget hiển thị các nút hành động
  Widget _buildActionButtons() {
    final streamingService = StreamingDataService();
    final isAvailable = streamingService.isAnimeAvailable(widget.anime.malId);

    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: Column(
        children: [
          // Nút xem anime (nếu có)
          if (isAvailable) ...[
            _buildWatchButton(),
            SizedBox(height: 12.h),
            // Nút lưu anime (chỉ hiển thị khi có nút xem)
            _buildSaveButton(),
          ],
        ],
      ),
    );
  }

  /// Widget nút xem anime
  Widget _buildWatchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _onWatchPressed,
        icon: Icon(Iconsax.play, color: Colors.white, size: 20.r),
        label: Text(
          'Xem Anime',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.animeTheme,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  /// Widget nút lưu anime (đơn giản chỉ hiển thị đã lưu/chưa lưu)
  Widget _buildSaveButton() {
    return Obx(() {
      final isAnimeInList = watchStatus.value != null;

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isAnimeInList
              ? null // Không cho phép bỏ lưu từ detail modal
              : (isLoadingStatus.value ? null : _onSavePressed),
          icon: isLoadingStatus.value
              ? SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  isAnimeInList ? Iconsax.heart5 : Iconsax.heart,
                  color: Colors.white,
                  size: 20.r,
                ),
          label: Text(
            isAnimeInList ? 'Đã lưu' : 'Lưu Anime',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isAnimeInList
                ? AppColors.success.withOpacity(0.8)
                : AppColors.animeTheme.withOpacity(0.8),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 1,
            disabledBackgroundColor: AppColors.success.withOpacity(0.6),
            disabledForegroundColor: Colors.white,
          ),
        ),
      );
    });
  }

  /// Xử lý khi nhấn nút xem
  Future<void> _onWatchPressed() async {
    final streamingService = StreamingDataService();
    final nguoncUrl = streamingService.getNguoncUrl(widget.anime.malId);

    if (nguoncUrl != null) {
      // Log để debug
      print('🎬 Navigating to watch screen:');
      print('   📋 MAL ID: ${widget.anime.malId}');
      print('   🏷️  Title: ${widget.anime.title}');
      print('   🔗 Nguonc URL: $nguoncUrl');

      // Đóng modal trước khi navigate
      Get.back();

      // Navigate đến anime watch screen với đầy đủ thông tin anime
      Get.toNamed(
        '/anime-watch',
        arguments: {
          'nguoncUrl': nguoncUrl,
          'animeTitle': widget.anime.title,
          'malId': widget.anime.malId,
          'animeData': widget.anime, // Truyền toàn bộ data anime
        },
      );
    } else {
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không tìm thấy link xem cho anime này',
        duration: const Duration(seconds: 2),
      );
    }
  }



  /// Xử lý khi nhấn nút lưu anime
  Future<void> _onSavePressed() async {
    final authService = AuthService.instance;
    final user = authService.currentUser!; // User đã đăng nhập rồi

    isLoadingStatus.value = true;

    try {
      final firestoreService = FirestoreService.instance;

      // Chỉ xử lý khi chưa lưu
      if (watchStatus.value != null) {
        // Đã lưu rồi, không làm gì
        isLoadingStatus.value = false;
        return;
      }

      // Thêm vào danh sách với trạng thái "Đã lưu"
      final newWatchStatus = AnimeWatchStatusModel.fromAnimeModel(widget.anime);
      final success = await firestoreService.saveAnimeWatchStatus(
        user.uid,
        newWatchStatus,
      );

      if (success) {
        watchStatus.value = newWatchStatus;
        NotificationHelper.showSuccess(
          title: 'Đã lưu',
          message: 'Đã lưu ${widget.anime.title} vào danh sách\nVào "Anime của tôi" để quản lý',
          duration: const Duration(seconds: 3),
        );
      } else {
        NotificationHelper.showError(
          title: 'Lỗi',
          message: 'Không thể lưu anime. Vui lòng thử lại.',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('❌ Error saving/removing anime: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Đã xảy ra lỗi. Vui lòng thử lại.',
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoadingStatus.value = false;
    }
  }
}
