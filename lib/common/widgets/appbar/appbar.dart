import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/device/device_utility.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../styles/spacing_styles.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustom({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showActionWithBadge = false,
    this.showBackArrow = false,
    required this.showActions,
    required this.showSkipButton,
    this.actionIcon,
    this.actionOnPressed,
    this.centerTitle = false,
  });

  final Widget? title;
  final bool showBackArrow;
  final bool showActions;
  final bool showSkipButton;
  final bool showActionWithBadge;
  final bool centerTitle;
  final IconData? leadingIcon;
  final IconData? actionIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  final VoidCallback? actionOnPressed;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return Padding(
      padding: SpacingStyle.paddingWithDefaultWidth,
      child: AppBar(
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0.0,
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
        automaticallyImplyLeading: false,
        leading:
            showBackArrow
                ? IconButton(onPressed: () =>
                Navigator.pop(context),
                icon: Icon(Iconsax.arrow_left_24,
                    color: dark ? AppColors.white : AppColors.dark,size: 25))
                : leadingIcon != null
                ? IconButton(onPressed: leadingOnPressed, icon: Icon(leadingIcon, color: dark ? AppColors.white : AppColors.dark))
                : null,
        title: title,
        actions:
            showSkipButton
                ? [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(6), textStyle: Theme.of(context).textTheme.bodySmall),
                    child: const Text(AppTexts.skip),
                  ),
                ]
                : showActions
                ? (actions != null)
                    ? actions
                    : [
                      showActionWithBadge
                          ? badges.Badge(
                            position: badges.BadgePosition.topEnd(top: 0, end: 0),
                            badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.primary),
                             child: IconButton(onPressed: actionOnPressed, icon: Icon(actionIcon, color: dark ? AppColors.white : AppColors.dark)),
                          )
                          : IconButton(onPressed: actionOnPressed, icon: Icon(actionIcon, color: dark ? AppColors.white : AppColors.dark)),
                    ]
                : null,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}
