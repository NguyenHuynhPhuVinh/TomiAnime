import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../anime/controllers/anime_controller.dart';
import '../../search/controllers/search_controller.dart';
import '../../account/controllers/account_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );

    // Đăng ký tất cả controller cho các tab trong HomeView
    Get.lazyPut<AnimeController>(
      () => AnimeController(),
    );

    Get.lazyPut<AnimeSearchController>(
      () => AnimeSearchController(),
    );

    Get.lazyPut<AccountController>(
      () => AccountController(),
    );
  }
}
