import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/character_search_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';
import '../../../models/character_model.dart';

class CharacterSearchView extends GetView<CharacterSearchController> {
  const CharacterSearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.search_normal,
              color: AppColors.accountTheme,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            Text('Chọn Avatar', style: AppTextStyles.h5),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
          onPressed: () => Get.back(),
        ),
        flexibleSpace: Container(
          decoration: AppDecorations.appBarWithThemeColor(AppColors.accountTheme),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDecorations.backgroundGradient,
        ),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        controller: controller.searchController,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm nhân vật anime...',
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Iconsax.search_normal,
            color: AppColors.accountTheme,
            size: 20.sp,
          ),
          suffixIcon: Obx(() => controller.searchText.value.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Iconsax.close_circle,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox()),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: AppDecorations.radiusM,
            borderSide: BorderSide(
              color: AppColors.accountTheme.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppDecorations.radiusM,
            borderSide: BorderSide(
              color: AppColors.accountTheme.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppDecorations.radiusM,
            borderSide: BorderSide(
              color: AppColors.accountTheme,
              width: 2,
            ),
          ),
        ),
        onSubmitted: controller.searchCharacters,
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (!controller.hasSearched.value) {
        return _buildInitialState();
      }

      if (controller.characters.isEmpty) {
        return _buildEmptyState();
      }

      return _buildCharacterGrid();
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.accountTheme.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accountTheme),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Đang tìm kiếm nhân vật...',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Vui lòng đợi trong giây lát',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.accountTheme.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.profile_2user,
              size: 60.r,
              color: AppColors.accountTheme,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Chọn Avatar từ Nhân vật Anime',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Tìm kiếm nhân vật yêu thích để làm ảnh đại diện',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.search_status,
              size: 60.r,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Không tìm thấy nhân vật',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Thử tìm kiếm với từ khóa khác\nhoặc kiểm tra chính tả',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterGrid() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: controller.characters.length,
      itemBuilder: (context, index) {
        final character = controller.characters[index];
        return _buildCharacterCard(character);
      },
    );
  }

  Widget _buildCharacterCard(CharacterModel character) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.selectCharacter(character),
          borderRadius: AppDecorations.radiusM,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDecorations.radiusM,
              border: Border.all(
                color: AppColors.accountTheme.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Avatar tròn
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accountTheme.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: character.images.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surface,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accountTheme),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surface,
                        child: Icon(
                          Iconsax.profile_circle,
                          color: AppColors.textTertiary,
                          size: 30.r,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // Thông tin nhân vật
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: AppTextStyles.buttonLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (character.nameKanji != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          character.nameKanji!,
                          style: AppTextStyles.captionMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (character.favorites > 0) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Iconsax.heart5,
                              size: 14.sp,
                              color: AppColors.accountTheme,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${_formatNumber(character.favorites)} lượt yêu thích',
                              style: AppTextStyles.captionMedium.copyWith(
                                color: AppColors.accountTheme,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Icon chọn
                Icon(
                  Iconsax.arrow_right_3,
                  color: AppColors.textTertiary,
                  size: 16.sp,
                ),
              ],
            ),
          ),
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
}
