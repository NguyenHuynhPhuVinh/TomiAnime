import 'package:get/get.dart';
import '../controllers/anime_watch_controller.dart';

class AnimeWatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnimeWatchController>(
      () => AnimeWatchController(),
    );
  }
}
