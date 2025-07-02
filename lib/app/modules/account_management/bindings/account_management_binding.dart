import 'package:get/get.dart';
import '../controllers/account_management_controller.dart';

class AccountManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountManagementController>(
      () => AccountManagementController(),
    );
  }
}
