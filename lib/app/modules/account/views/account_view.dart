import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:getwidget/getwidget.dart';
import '../controllers/account_controller.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/user_model.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.profile_circle,
              color: Colors.orange,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            const Text('Player Profile'),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.withOpacity(0.1),
                Colors.deepOrange.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildUserProfile(),
              SizedBox(height: 30.h),
              _buildMenuItems(),
              SizedBox(height: 30.h),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    final authService = AuthService.instance;
    final firestoreService = FirestoreService.instance;
    final user = authService.currentUser;

    if (user == null) {
      return Container(
        padding: EdgeInsets.all(20.w),
        child: Text(
          'Chưa đăng nhập',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return FutureBuilder<UserModel?>(
      future: firestoreService.getUser(user.uid),
      builder: (context, snapshot) {
        final userModel = snapshot.data;

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacity(0.1),
                Colors.deepOrange.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.orange.withOpacity(0.3),
                      Colors.orange.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.profile_circle,
                  size: 60.r,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                userModel?.displayName ?? user.displayName ?? 'Người dùng',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                userModel?.email ?? user.email ?? 'email@example.com',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[400],
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Iconsax.setting_2,
          title: 'Cài đặt',
          subtitle: 'Tùy chỉnh ứng dụng',
          onTap: () {
            Get.snackbar(
              'Thông báo',
              'Tính năng đang phát triển',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        SizedBox(height: 12.h),
        _buildMenuItem(
          icon: Iconsax.heart,
          title: 'Yêu thích',
          subtitle: 'Anime đã lưu',
          onTap: () {
            Get.snackbar(
              'Thông báo',
              'Tính năng đang phát triển',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        SizedBox(height: 12.h),
        _buildMenuItem(
          icon: Iconsax.info_circle,
          title: 'Về ứng dụng',
          subtitle: 'Thông tin phiên bản',
          onTap: () {
            Get.snackbar(
              'TomiAnime',
              'Phiên bản 1.0.0\nPhát triển bởi TomiSakae',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.orange.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: Colors.orange,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: Colors.grey[400],
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    final authService = AuthService.instance;

    return GFButton(
      onPressed: () async {
        Get.dialog(
          AlertDialog(
            backgroundColor: const Color(0xFF1A1F3A),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Bạn có chắc chắn muốn đăng xuất?',
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  Get.back();
                  await authService.signOut();
                  Get.offAllNamed('/login');
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      text: 'Đăng xuất',
      size: GFSize.LARGE,
      fullWidthButton: true,
      color: Colors.red,
      shape: GFButtonShape.pills,
      icon: Icon(
        Iconsax.logout,
        color: Colors.white,
        size: 20.sp,
      ),
      textStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
