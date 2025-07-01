import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../firebase_options.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/streaming_data_service.dart';

class SplashController extends GetxController {
  // Observable variables
  final RxDouble logoSize = 100.0.obs;
  final RxDouble textOpacity = 0.0.obs;
  final RxString loadingText = 'Đang khởi động...'.obs;

  @override
  void onInit() {
    super.onInit();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    // Start animations
    _startAnimations();

    try {
      // Step 1: Initialize Firebase (thực tế)
      loadingText.value = 'Đang kết nối server...';
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized');

      // Step 2: Setup Hive Database (thực tế)
      loadingText.value = 'Đang thiết lập cơ sở dữ liệu...';
      await Hive.initFlutter();
      print('✅ Hive database setup completed');

      // Step 3: Initialize Services (thực tế)
      loadingText.value = 'Đang khởi tạo dịch vụ...';
      Get.put(FirestoreService());
      Get.put(AuthService());

      // Initialize Streaming Data Service
      final streamingService = StreamingDataService();
      await streamingService.init();
      Get.put(streamingService);

      print('✅ All services initialized');

      // Step 4: Check Authentication (thực tế)
      loadingText.value = 'Đang kiểm tra tài khoản...';
      final authService = Get.find<AuthService>();
      await Future.delayed(const Duration(milliseconds: 500));
      print('✅ Authentication checked');
      print('🔐 User logged in: ${authService.isLoggedIn}');

      // Step 5: Sync Streaming Data (thực tế - mất thời gian thật)
      loadingText.value = 'Đang cập nhật dữ liệu anime...';
      print('🔄 Starting streaming data sync...');
      final synced = await streamingService.syncFromGitHub();

      if (synced) {
        print('✅ Streaming data synced successfully');
      } else {
        print('ℹ️ Streaming data is up to date');
      }

      final count = streamingService.getAvailableAnimeCount();
      print('📊 Available anime count: $count');

      // Step 6: Finalization (thực tế)
      loadingText.value = 'Đang hoàn tất...';
      print('🔍 Verifying services...');
      print('   Auth ready: ${authService.isLoggedIn}');
      print('   Streaming ready: ${count >= 0}');

      print('🎉 App initialization completed successfully');

      // Navigate to appropriate screen
      _navigateToNextScreen();
    } catch (e) {
      print('❌ Error during initialization: $e');
      _handleInitializationError(e);
    }
  }



  void _startAnimations() {
    // Logo size animation
    Future.delayed(const Duration(milliseconds: 300), () {
      logoSize.value = 120.0;
    });

    // Text fade in
    Future.delayed(const Duration(milliseconds: 600), () {
      textOpacity.value = 1.0;
    });
  }

  void _navigateToNextScreen() {
    final authService = Get.find<AuthService>();

    if (authService.isLoggedIn) {
      // User is logged in, go to main app
      Get.offAllNamed('/home'); // Sử dụng path trực tiếp
    } else {
      // User not logged in, go to login
      Get.offAllNamed('/login'); // Sử dụng path trực tiếp
    }
  }

  void _handleInitializationError(dynamic error) {
    Get.snackbar(
      'Lỗi khởi tạo',
      'Có lỗi xảy ra khi khởi tạo ứng dụng: $error',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
    );

    // Retry after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _startInitialization();
    });
  }

  // Method to manually retry initialization
  void retryInitialization() {
    _startInitialization();
  }
}
