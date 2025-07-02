import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../utils/notification_helper.dart';

class InfoController extends GetxController {
  final Rx<PackageInfo?> packageInfo = Rx<PackageInfo?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPackageInfo();
  }

  Future<void> loadPackageInfo() async {
    try {
      isLoading.value = true;
      final info = await PackageInfo.fromPlatform();
      packageInfo.value = info;
    } catch (e) {
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể tải thông tin ứng dụng',
      );
    } finally {
      isLoading.value = false;
    }
  }

  String get appName => packageInfo.value?.appName ?? 'TomiAnime';
  String get version => packageInfo.value?.version ?? '1.0.0';
  String get buildNumber => packageInfo.value?.buildNumber ?? '1';
  String get packageName => packageInfo.value?.packageName ?? 'com.tomianime.app';
}
