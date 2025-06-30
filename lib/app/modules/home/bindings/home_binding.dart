import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../anime/controllers/anime_controller.dart';
import '../../cards/controllers/cards_controller.dart';
import '../../adventure/controllers/adventure_controller.dart';
import '../../gacha/controllers/gacha_controller.dart';
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

    Get.lazyPut<CardsController>(
      () => CardsController(),
    );

    Get.lazyPut<AdventureController>(
      () => AdventureController(),
    );

    Get.lazyPut<GachaController>(
      () => GachaController(),
    );

    Get.lazyPut<AccountController>(
      () => AccountController(),
    );
  }
}
