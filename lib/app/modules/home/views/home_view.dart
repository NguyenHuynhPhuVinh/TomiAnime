import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../controllers/home_controller.dart';
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 20.r,
            color: Colors.purple.withOpacity(0.2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.purple.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 75.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGameNavItem(0, Iconsax.play, 'Anime', Colors.red, true),
                _buildGameNavItem(
                  1,
                  Iconsax.card,
                  'Cards',
                  Colors.blue,
                  true,
                ),
                _buildGameNavItem(
                  2,
                  Iconsax.map,
                  'Quest',
                  Colors.green,
                  true,
                ),
                _buildGameNavItem(
                  3,
                  Iconsax.gift,
                  'Gacha',
                  Colors.purple,
                  true,
                ),
                _buildGameNavItem(
                  4,
                  Iconsax.profile_circle,
                  'Profile',
                  Colors.orange,
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 20.r,
            color: Colors.purple.withOpacity(0.2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.purple.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 80.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGameNavItem(0, Iconsax.play, 'Anime', Colors.red, false),
                _buildGameNavItem(
                  1,
                  Iconsax.card,
                  'Cards',
                  Colors.blue,
                  false,
                ),
                _buildGameNavItem(
                  2,
                  Iconsax.map,
                  'Quest',
                  Colors.green,
                  false,
                ),
                _buildGameNavItem(
                  3,
                  Iconsax.gift,
                  'Gacha',
                  Colors.purple,
                  false,
                ),
                _buildGameNavItem(
                  4,
                  Iconsax.profile_circle,
                  'Profile',
                  Colors.orange,
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
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      themeColor.withOpacity(0.2),
                      themeColor.withOpacity(0.1),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(12.r),
            border: isSelected
                ? Border.all(color: themeColor.withOpacity(0.5), width: 1.5)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themeColor.withOpacity(0.3),
                      blurRadius: 8.r,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
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
                      : Colors.grey[400],
                ),
              ),
              SizedBox(height: 2.h),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile
                        ? (isSelected ? 8.sp : 7.sp)
                        : (isSelected ? 10.sp : 9.sp),
                    color: isSelected
                        ? themeColor
                        : Colors.grey[400],
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.2,
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
                    borderRadius: BorderRadius.circular(1.r),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
