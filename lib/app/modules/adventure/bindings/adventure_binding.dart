import 'package:get/get.dart';
import '../controllers/adventure_controller.dart';

class AdventureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdventureController>(
      () => AdventureController(),
    );
  }
}
