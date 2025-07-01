import 'package:get/get.dart';
import '../controllers/anime_search_controller.dart';

class AnimeSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnimeSearchController>(() => AnimeSearchController());
  }
}
