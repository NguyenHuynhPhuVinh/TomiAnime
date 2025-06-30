import 'package:get/get.dart';
import '../middlewares/auth_middleware.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/anime/bindings/anime_binding.dart';
import '../modules/anime/views/anime_view.dart';
import '../modules/cards/bindings/cards_binding.dart';
import '../modules/cards/views/cards_view.dart';
import '../modules/adventure/bindings/adventure_binding.dart';
import '../modules/adventure/views/adventure_view.dart';
import '../modules/gacha/bindings/gacha_binding.dart';
import '../modules/gacha/views/gacha_view.dart';
import '../modules/account/bindings/account_binding.dart';
import '../modules/account/views/account_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.AUTH;

  static final routes = [
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ANIME,
      page: () => const AnimeView(),
      binding: AnimeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.CARDS,
      page: () => const CardsView(),
      binding: CardsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ADVENTURE,
      page: () => const AdventureView(),
      binding: AdventureBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.GACHA,
      page: () => const GachaView(),
      binding: GachaBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ACCOUNT,
      page: () => const AccountView(),
      binding: AccountBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
