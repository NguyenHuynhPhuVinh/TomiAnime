import 'package:get/get.dart';
import '../controllers/anime_list_controller.dart';

class AnimeListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnimeListController>(() => AnimeListController());
  }
}
