import 'package:get/get.dart';
import '../controllers/achievement_quest_controller.dart';

class AchievementQuestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AchievementQuestController>(
      () => AchievementQuestController(),
    );
  }
}
