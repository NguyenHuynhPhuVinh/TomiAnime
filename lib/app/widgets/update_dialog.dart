import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/app_update_model.dart';
import '../services/app_update_service.dart';

class UpdateDialog {
  static void show(AppUpdateModel updateInfo) {
    Get.dialog(
      _UpdateDialogContent(updateInfo: updateInfo),
      barrierDismissible: !updateInfo.forceUpdate,
    );
  }

  /// Hiển thị dialog blocking tại splash screen
  static void showBlocking(
    AppUpdateModel updateInfo, {
    required VoidCallback onUpdateCompleted,
  }) {
    Get.dialog(
      _UpdateDialogContent(
        updateInfo: updateInfo,
        onUpdateCompleted: onUpdateCompleted,
        isBlocking: true,
      ),
      barrierDismissible: false, // Luôn block, không thể dismiss
      useSafeArea: false,
    );
  }
}

class _UpdateDialogContent extends StatefulWidget {
  final AppUpdateModel updateInfo;
  final VoidCallback? onUpdateCompleted;
  final bool isBlocking;

  const _UpdateDialogContent({
    Key? key,
    required this.updateInfo,
    this.onUpdateCompleted,
    this.isBlocking = false,
  }) : super(key: key);

  @override
  State<_UpdateDialogContent> createState() => _UpdateDialogContentState();
}

class _UpdateDialogContentState extends State<_UpdateDialogContent> {
  final RxBool isDownloading = false.obs;
  final AppUpdateService _updateService = AppUpdateService();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.animeTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Iconsax.refresh,
                    color: AppColors.animeTheme,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cập nhật mới',
                        style: AppTextStyles.h5.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Phiên bản ${widget.updateInfo.version}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.animeTheme,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            
            // Changelog
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Có gì mới:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.updateInfo.changelog,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            if (widget.updateInfo.forceUpdate) ...[
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.warning_2,
                      color: AppColors.warning,
                      size: 16.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Cập nhật bắt buộc để tiếp tục sử dụng',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 24.h),
            
            // Buttons
            Obx(() => Row(
              children: [
                if (!widget.updateInfo.forceUpdate && !isDownloading.value && !widget.isBlocking) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        widget.onUpdateCompleted?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.outline),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Để sau',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isDownloading.value ? null : _downloadUpdate,
                    icon: isDownloading.value
                        ? SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.r,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            Iconsax.arrow_down_1,
                            size: 16.r,
                            color: Colors.white,
                          ),
                    label: Text(
                      isDownloading.value ? 'Đang tải...' : 'Cập nhật',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.animeTheme,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadUpdate() async {
    isDownloading.value = true;
    
    try {
      final success = await _updateService.downloadAndInstallApk(widget.updateInfo);
      
      if (success) {
        Get.back();
        widget.onUpdateCompleted?.call();
        Get.snackbar(
          'Thành công',
          'Đang cài đặt cập nhật... File APK sẽ tự động xóa sau 30 giây.',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          icon: Icon(Iconsax.tick_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          'Lỗi',
          'Không thể tải cập nhật. Vui lòng thử lại.',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          icon: Icon(Iconsax.close_circle, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Có lỗi xảy ra: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        icon: Icon(Iconsax.close_circle, color: Colors.white),
      );
    } finally {
      isDownloading.value = false;
    }
  }
}
