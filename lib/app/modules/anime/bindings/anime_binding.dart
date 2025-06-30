import 'package:get/get.dart';
import '../controllers/anime_controller.dart';

class AnimeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnimeController>(
      () => AnimeController(),
    );
  }
}
