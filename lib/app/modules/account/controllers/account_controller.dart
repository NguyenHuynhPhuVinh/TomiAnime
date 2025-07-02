import 'package:get/get.dart';
import '../../../controllers/user_resource_controller.dart';

class AccountController extends GetxController {
  late UserResourceController userResourceController;

  @override
  void onInit() {
    super.onInit();
    // Khởi tạo UserResourceController nếu chưa có
    if (!Get.isRegistered<UserResourceController>()) {
      Get.put(UserResourceController());
    }
    userResourceController = UserResourceController.instance;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
