import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../controllers/home_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_decorations.dart';
import '../../anime/views/anime_view.dart';
import '../../cards/views/cards_view.dart';
import '../../adventure/views/adventure_view.dart';
import '../../gacha/views/gacha_view.dart';
import '../../account/views/account_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            AnimeView(),
            CardsView(),
            AdventureView(),
            GachaView(),
            AccountView(),
          ],
        ),
      ),
      bottomNavigationBar: _buildResponsiveNavBar(),
    );
  }

  Widget _buildResponsiveNavBar() {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
          return _buildMobileNavBar();
        } else {
          return _buildTabletNavBar();
        }
      },
    );
  }

  Widget _buildMobileNavBar() {
    return Container(
      decoration: AppDecorations.navBarDecoration,
      child: SafeArea(
        child: Container(
          height: 75.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGameNavItem(0, Iconsax.play, 'Anime', AppColors.animeTheme, true),
                _buildGameNavItem(
                  1,
                  Iconsax.card,
                  'Cards',
                  AppColors.cardsTheme,
                  true,
                ),
                _buildGameNavItem(
                  2,
                  Iconsax.map,
                  'Quest',
                  AppColors.adventureTheme,
                  true,
                ),
                _buildGameNavItem(
                  3,
                  Iconsax.gift,
                  'Gacha',
                  AppColors.gachaTheme,
                  true,
                ),
                _buildGameNavItem(
                  4,
                  Iconsax.profile_circle,
                  'Profile',
                  AppColors.accountTheme,
                  true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletNavBar() {
    return Container(
      decoration: AppDecorations.navBarDecoration,
      child: SafeArea(
        child: Container(
          height: 80.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGameNavItem(0, Iconsax.play, 'Anime', AppColors.animeTheme, false),
                _buildGameNavItem(
                  1,
                  Iconsax.card,
                  'Cards',
                  AppColors.cardsTheme,
                  false,
                ),
                _buildGameNavItem(
                  2,
                  Iconsax.map,
                  'Quest',
                  AppColors.adventureTheme,
                  false,
                ),
                _buildGameNavItem(
                  3,
                  Iconsax.gift,
                  'Gacha',
                  AppColors.gachaTheme,
                  false,
                ),
                _buildGameNavItem(
                  4,
                  Iconsax.profile_circle,
                  'Profile',
                  AppColors.accountTheme,
                  false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameNavItem(
    int index,
    IconData icon,
    String label,
    Color themeColor,
    bool isMobile,
  ) {
    final isSelected = controller.currentIndex.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTabIndex(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 1.w : 4.w,
            vertical: isMobile ? 6.h : 8.h,
          ),
          decoration: AppDecorations.containerWithThemeColor(themeColor, isSelected: isSelected),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(isSelected ? 4.r : 3.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? themeColor.withOpacity(0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isMobile
                      ? (isSelected ? 18.r : 16.r)
                      : (isSelected ? 22.r : 20.r),
                  color: isSelected
                      ? themeColor
                      : AppColors.textTertiary,
                ),
              ),
              SizedBox(height: 2.h),
              Flexible(
                child: Text(
                  label,
                  style: isSelected
                    ? AppTextStyles.withSize(
                        AppTextStyles.withColor(AppTextStyles.navLabelSelected, themeColor),
                        isMobile ? 8 : 10,
                      )
                    : AppTextStyles.withSize(
                        AppTextStyles.withColor(AppTextStyles.navLabel, AppColors.textTertiary),
                        isMobile ? 7 : 9,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Container(
                  margin: EdgeInsets.only(top: 2.h),
                  height: 2.h,
                  width: 20.w,
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: AppDecorations.radiusXS,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
