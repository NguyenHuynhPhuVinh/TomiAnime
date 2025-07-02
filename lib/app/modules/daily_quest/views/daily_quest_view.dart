import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/daily_quest_controller.dart';
import '../../../models/daily_quest_model.dart';
import '../../../models/daily_reward_chest_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';

class DailyQuestView extends GetView<DailyQuestController> {
  const DailyQuestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.task_square,
              color: AppColors.primary,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            Text('Nhiệm vụ hàng ngày', style: AppTextStyles.h5),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: AppDecorations.appBarWithThemeColor(AppColors.primary),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDecorations.backgroundGradient,
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDailyProgress(),
                SizedBox(height: 20.h),
                _buildQuestSection(),
                SizedBox(height: 20.h),
                _buildRewardChestSection(),
                SizedBox(height: 20.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDailyProgress() {
    return Obx(() {
      final questController = controller;
      final progress = questController.dailyProgress;
      final completedCount = questController.completedQuestsCount;
      final totalCount = questController.totalQuestsCount;
      final dailyPoints = questController.currentDailyPoints.value;

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primaryLight.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiến độ hôm nay',
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$completedCount/$totalCount nhiệm vụ',
                      style: AppTextStyles.captionLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.star,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$dailyPoints',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhiệm vụ hàng ngày',
          style: AppTextStyles.h4,
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final quests = controller.dailyQuests;
          
          if (quests.isEmpty) {
            return Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.5),
                borderRadius: AppDecorations.radiusM,
              ),
              child: Center(
                child: Text(
                  'Không có nhiệm vụ nào',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          return Column(
            children: quests.map((quest) => _buildQuestItem(quest)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildQuestItem(DailyQuestModel quest) {
    final isCompleted = quest.isCompleted;
    final questColor = _getQuestTypeColor(quest.type);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withOpacity(0.3)
              : questColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: questColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              _getQuestTypeIcon(quest.type),
              color: questColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        quest.title,
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${quest.currentValue}/${quest.targetValue}',
                      style: AppTextStyles.captionMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.r),
                    child: LinearProgressIndicator(
                      value: quest.progressPercentage,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(questColor),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        quest.reward.description,
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _buildQuestActionButton(quest),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestActionButton(DailyQuestModel quest) {
    if (quest.status == QuestStatus.claimed) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.tick_circle,
              color: AppColors.success,
              size: 12.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              'Đã nhận',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (quest.isCompleted) {
      return Obx(() {
        final isLoading = controller.isClaimingReward.value;

        return GestureDetector(
          onTap: isLoading ? null : () => controller.claimQuestReward(quest.id),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: isLoading
                ? SizedBox(
                    width: 12.w,
                    height: 12.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.gift,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Nhận',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      });
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.textTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        '${(quest.progressPercentage * 100).toInt()}%',
        style: AppTextStyles.captionSmall.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getQuestTypeIcon(QuestType type) {
    switch (type) {
      case QuestType.login:
        return Iconsax.login;
      case QuestType.watchEpisode:
        return Iconsax.play;
      case QuestType.onlineTime:
        return Iconsax.clock;
      case QuestType.viewAnimeInfo:
        return Iconsax.info_circle;
    }
  }

  Color _getQuestTypeColor(QuestType type) {
    switch (type) {
      case QuestType.login:
        return AppColors.success;
      case QuestType.watchEpisode:
        return AppColors.primary;
      case QuestType.onlineTime:
        return AppColors.warning;
      case QuestType.viewAnimeInfo:
        return AppColors.info;
    }
  }

  Widget _buildRewardChestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hòm quà hàng ngày',
          style: AppTextStyles.h4,
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final chests = controller.rewardChests;

          if (chests.isEmpty) {
            return Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.5),
                borderRadius: AppDecorations.radiusM,
              ),
              child: Center(
                child: Text(
                  'Không có hòm quà nào',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          return Row(
            children: chests.asMap().entries.map((entry) {
              final index = entry.key;
              final chest = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 6.w,
                    right: index == chests.length - 1 ? 0 : 6.w,
                  ),
                  child: _buildChestItem(chest),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildChestItem(DailyRewardChestModel chest) {
    final isLocked = chest.status == ChestStatus.locked;
    final isAvailable = chest.status == ChestStatus.available;
    final isOpened = chest.status == ChestStatus.opened;
    final chestColor = _getChestColor(chest.type);

    return GestureDetector(
      onTap: isAvailable
          ? () => controller.openRewardChest(chest.id)
          : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: chestColor.withOpacity(isLocked ? 0.1 : 0.15),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: chestColor.withOpacity(isAvailable ? 0.8 : 0.3),
            width: isAvailable ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: chestColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Iconsax.gift,
                    color: chestColor,
                    size: 20.sp,
                  ),
                ),
                if (isLocked)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Iconsax.lock,
                        color: AppColors.textTertiary,
                        size: 10.sp,
                      ),
                    ),
                  ),
                if (isOpened)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Iconsax.tick_circle,
                        color: AppColors.success,
                        size: 10.sp,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              chest.title,
              style: AppTextStyles.captionMedium.copyWith(
                color: chestColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              '${chest.requiredDailyPoints} điểm',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.center,
            ),
            if (isAvailable) ...[
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'MỞ',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getChestColor(ChestType type) {
    switch (type) {
      case ChestType.bronze:
        return Colors.brown;
      case ChestType.silver:
        return Colors.grey;
      case ChestType.gold:
        return Colors.amber;
      case ChestType.diamond:
        return Colors.cyan;
    }
  }
}
