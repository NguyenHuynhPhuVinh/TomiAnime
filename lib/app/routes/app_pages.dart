import 'package:get/get.dart';
import '../middlewares/auth_middleware.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/bindings/login_binding.dart';
import '../modules/auth/bindings/register_binding.dart';
import '../modules/auth/bindings/forgot_password_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/anime/bindings/anime_binding.dart';
import '../modules/anime/views/anime_view.dart';
import '../modules/anime/bindings/anime_search_binding.dart';
import '../modules/anime/views/anime_search_view.dart';
import '../modules/anime_watch/bindings/anime_watch_binding.dart';
import '../modules/anime_watch/views/anime_watch_view.dart';
import '../modules/anime_list/bindings/anime_list_binding.dart';
import '../modules/anime_list/views/anime_list_view.dart';
import '../modules/video_player/bindings/video_player_binding.dart';
import '../modules/video_player/views/video_player_view.dart';
import '../modules/cards/bindings/cards_binding.dart';
import '../modules/cards/views/cards_view.dart';
import '../modules/adventure/bindings/adventure_binding.dart';
import '../modules/adventure/views/adventure_view.dart';
import '../modules/gacha/bindings/gacha_binding.dart';
import '../modules/gacha/views/gacha_view.dart';
import '../modules/account/bindings/account_binding.dart';
import '../modules/account/views/account_view.dart';
import '../modules/info/bindings/info_binding.dart';
import '../modules/info/views/info_view.dart';
import '../modules/account_management/bindings/account_management_binding.dart';
import '../modules/account_management/views/account_management_view.dart';
import '../modules/character_search/bindings/character_search_binding.dart';
import '../modules/character_search/views/character_search_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
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
      name: _Paths.ANIME_SEARCH,
      page: () => const AnimeSearchView(),
      binding: AnimeSearchBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ANIME_WATCH,
      page: () => const AnimeWatchView(),
      binding: AnimeWatchBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ANIME_LIST,
      page: () => const AnimeListView(),
      binding: AnimeListBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.VIDEO_PLAYER,
      page: () => const VideoPlayerView(),
      binding: VideoPlayerBinding(),
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
    GetPage(
      name: _Paths.INFO,
      page: () => const InfoView(),
      binding: InfoBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ACCOUNT_MANAGEMENT,
      page: () => const AccountManagementView(),
      binding: AccountManagementBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.CHARACTER_SEARCH,
      page: () => const CharacterSearchView(),
      binding: CharacterSearchBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
