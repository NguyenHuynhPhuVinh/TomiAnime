import 'package:get/get.dart';
import '../controllers/daily_quest_controller.dart';

class DailyQuestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyQuestController>(
      () => DailyQuestController(),
    );
  }
}
