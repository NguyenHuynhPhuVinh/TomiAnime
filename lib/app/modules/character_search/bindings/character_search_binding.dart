import 'package:get/get.dart';
import '../controllers/character_search_controller.dart';

class CharacterSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CharacterSearchController>(
      () => CharacterSearchController(),
    );
  }
}
