import 'package:fit_store/common/widgets/appbar/appbar.dart';
import 'package:fit_store/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:fit_store/common/widgets/list_tile/user_profile_tile.dart';
import 'package:fit_store/common/widgets/texts/section_heading.dart';
import 'package:fit_store/features/settings/presentation/screens/widgets/setting_menu_tile.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../cart/presentation/screens/cart.dart';
import '../controllers/theme/theme_controller_provider.dart';
import 'address/user_address.dart';
import 'order/order.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            PrimaryHeaderContainer(
              child: Column(
                children: [
                  AppBarCustom(
                    showActions: false,
                    showSkipButton: false,
                    title: Text(
                      'Account',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.apply(color: Colors.white),
                    ),
                  ),
                  const UserProfileTile(),
                  SizedBox(height: AppSizes.spaceBtwSections),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                children: [
                  const SectionHeading(
                    title: 'Account Setting',
                    showActionButton: false,
                  ),
                  SizedBox(height: AppSizes.spaceBtwItems),
                  SettingMenuTile(
                    icon: Iconsax.safe_home,
                    title: 'My Addresses',
                    subTitle: 'Set shopping delivery address',
                    onTap: () {
                      Navigator.pushNamed(context, UserAddressScreen.routeName);
                    },
                  ),
                  SizedBox(height: AppSizes.spaceBtwItems),
                  SettingMenuTile(
                    icon: Iconsax.shopping_cart,
                    title: 'My Cart',
                    subTitle: 'Add, remove products and move to checkout',
                    onTap: () {
                      Navigator.pushNamed(context, CartScreen.routeName);
                    },
                  ),
                  SizedBox(height: AppSizes.spaceBtwItems),
                  SettingMenuTile(
                    icon: Iconsax.bag_tick,
                    title: 'My Orders',
                    subTitle: 'In-progress and Completed Orders',
                    onTap: () {
                      Navigator.pushNamed(context, OrderScreen.routeName);
                    },
                  ),
                  SizedBox(height: AppSizes.spaceBtwSections),
                  SectionHeading(title: 'App Setting', showActionButton: false),
                  SizedBox(height: AppSizes.spaceBtwItems),
                  SettingMenuTile(
                    icon: Iconsax.moon,
                    title: 'App Theme',
                    subTitle: _getThemeSubTitle(
                      context.watch<ThemeController>().themeMode,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16.r),
                    onTap: () {
                      _showThemeBottomSheet(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeSubTitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  void _showThemeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Consumer<ThemeController>(
          builder: (context, themeController, child) {
            return Padding(
              padding: EdgeInsets.all(20.r),
              child: RadioGroup<ThemeMode>(
                groupValue: themeController.themeMode,
                onChanged: (ThemeMode? mode) {
                  if (mode != null) {
                    themeController.setThemeMode(mode);
                    Navigator.pop(context);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose App Theme',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    RadioListTile<ThemeMode>(
                      title: const Text('System Default'),
                      subtitle: const Text('Follow device theme settings'),
                      value: ThemeMode.system,
                    ),

                    RadioListTile<ThemeMode>(
                      title: const Text('Light Mode'),
                      value: ThemeMode.light,
                    ),

                    RadioListTile<ThemeMode>(
                      title: const Text('Dark Mode'),
                      value: ThemeMode.dark,
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
