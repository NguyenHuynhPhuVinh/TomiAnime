import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/app_update_model.dart';

class AppUpdateService {
  static const String _boxName = 'app_update';
  static const String _lastCheckKey = 'last_check_time';
  
  // URL của JSON file update trên GitHub - cập nhật URL này
  static const String updateJsonUrl = 'https://raw.githubusercontent.com/NguyenHuynhPhuVinh/TomiAnimeData/refs/heads/main/app_update.json';
  
  late final Box _box;
  final Dio _dio = Dio();
  
  // Singleton pattern
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();
  
  /// Khởi tạo service
  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);

      // Xóa các APK cũ khi khởi tạo
      await cleanupOldApks();

      print('AppUpdateService initialized successfully');
    } catch (e) {
      print('Error initializing AppUpdateService: $e');
      rethrow;
    }
  }
  
  /// Kiểm tra cập nhật từ GitHub
  Future<AppUpdateModel?> checkForUpdate() async {
    try {
      print('🔍 Checking for app updates...');
      
      // Lấy thông tin app hiện tại
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      print('📱 Current app version: $currentVersion');
      
      // Tải thông tin update từ GitHub
      final response = await _dio.get(updateJsonUrl);
      
      if (response.statusCode == 200) {
        final jsonData = response.data is String 
          ? json.decode(response.data) 
          : response.data;
          
        final updateInfo = AppUpdateModel.fromJson(jsonData);
        
        print('🆕 Latest version available: ${updateInfo.version}');
        print('📦 Download URL: ${updateInfo.downloadUrl}');
        print('🔄 Force update: ${updateInfo.forceUpdate}');
        
        // So sánh version
        if (updateInfo.isNewerThan(currentVersion)) {
          print('✅ New update available!');
          await _saveLastCheckTime();
          return updateInfo;
        } else {
          print('ℹ️ App is up to date');
          await _saveLastCheckTime();
          return null;
        }
      } else {
        throw Exception('Failed to fetch update info: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error checking for updates: $e');
      return null;
    }
  }
  
  /// Tải và cài đặt APK
  Future<bool> downloadAndInstallApk(AppUpdateModel updateInfo) async {
    try {
      print('📥 Starting APK download...');
      
      // Kiểm tra quyền
      if (!await _requestPermissions()) {
        print('❌ Permissions denied');
        return false;
      }
      
      // Lấy thư mục download
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        print('❌ Cannot access external storage');
        return false;
      }
      
      final downloadPath = '${directory.path}/TomiAnime_${updateInfo.version}.apk';
      
      // Xóa file cũ nếu có
      final file = File(downloadPath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Tải APK
      await _dio.download(
        updateInfo.downloadUrl,
        downloadPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(1);
            print('📥 Download progress: $progress%');
          }
        },
      );
      
      print('✅ APK downloaded successfully: $downloadPath');
      
      // Mở file để cài đặt
      final result = await OpenFile.open(downloadPath);

      if (result.type == ResultType.done) {
        print('✅ APK installation started');

        // Tự động xóa APK sau khi mở để cài đặt
        _scheduleApkCleanup(downloadPath);

        return true;
      } else {
        print('❌ Failed to open APK: ${result.message}');

        // Xóa APK nếu không thể mở
        await _deleteApkFile(downloadPath);

        return false;
      }
      
    } catch (e) {
      print('❌ Error downloading/installing APK: $e');
      return false;
    }
  }
  
  /// Kiểm tra quyền cần thiết
  Future<bool> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;

        // Android 13+ (API 33+) không cần WRITE_EXTERNAL_STORAGE
        if (androidInfo.version.sdkInt >= 33) {
          // Chỉ cần quyền install packages
          final installPermission = await Permission.requestInstallPackages.request();
          print('Install permission: ${installPermission.isGranted}');
          return installPermission.isGranted;
        } else {
          // Android 12 và thấp hơn cần storage permission
          final installPermission = await Permission.requestInstallPackages.request();
          final storagePermission = await Permission.storage.request();

          print('Install permission: ${installPermission.isGranted}');
          print('Storage permission: ${storagePermission.isGranted}');

          return installPermission.isGranted && storagePermission.isGranted;
        }
      }

      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }
  
  /// Lưu thời gian check cuối
  Future<void> _saveLastCheckTime() async {
    try {
      await _box.put(_lastCheckKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving last check time: $e');
    }
  }
  
  /// Lấy thời gian check cuối
  DateTime? getLastCheckTime() {
    try {
      final timeString = _box.get(_lastCheckKey);
      if (timeString == null) return null;
      return DateTime.tryParse(timeString);
    } catch (e) {
      print('Error getting last check time: $e');
      return null;
    }
  }
  
  /// Kiểm tra xem có nên check update không (dựa trên thời gian)
  bool shouldCheckForUpdate({Duration maxAge = const Duration(hours: 24)}) {
    final lastCheck = getLastCheckTime();
    if (lastCheck == null) return true;
    
    return DateTime.now().difference(lastCheck) > maxAge;
  }
  
  /// Lấy thông tin app hiện tại
  Future<Map<String, String>> getCurrentAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'packageName': packageInfo.packageName,
        'appName': packageInfo.appName,
      };
    } catch (e) {
      print('Error getting app info: $e');
      return {};
    }
  }

  /// Lên lịch xóa APK sau khi cài đặt
  void _scheduleApkCleanup(String apkPath) {
    // Đợi 30 giây sau khi mở APK để user có thời gian cài đặt
    Future.delayed(const Duration(seconds: 30), () async {
      await _deleteApkFile(apkPath);
    });
  }

  /// Xóa file APK
  Future<void> _deleteApkFile(String apkPath) async {
    try {
      final file = File(apkPath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ APK file deleted: $apkPath');
      }
    } catch (e) {
      print('❌ Error deleting APK file: $e');
    }
  }

  /// Xóa tất cả APK cũ trong thư mục download
  Future<void> cleanupOldApks() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return;

      final files = directory.listSync();
      for (final file in files) {
        if (file.path.endsWith('.apk') && file.path.contains('TomiAnime')) {
          try {
            await file.delete();
            print('🗑️ Deleted old APK: ${file.path}');
          } catch (e) {
            print('❌ Error deleting ${file.path}: $e');
          }
        }
      }
    } catch (e) {
      print('❌ Error cleaning up old APKs: $e');
    }
  }
}
