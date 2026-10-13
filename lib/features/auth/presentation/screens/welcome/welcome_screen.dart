import 'package:fit_store/utils/constants/colors.dart';
import 'package:fit_store/utils/constants/image_strings.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:fit_store/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../login/login_screen.dart';
import '../signup/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  static const routeName = '/welcome-screen';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode ? AppColors.secondary : Colors.lightBlue,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.defaultSpace),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image(
                  image: const AssetImage(AppImages.welcomeScreenImage),
                  width: 0.7.sw,
                  height: 0.6.sh,
                ),
                SizedBox(height: AppSizes.spaceBtwSections),
                Column(
                  children: [
                    Text(
                      AppTexts.welcomeTitle,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: AppSizes.sm),
                    Text(
                      AppTexts.welcomeSubTitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.spaceBtwSections),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, LoginScreen.routeName),
                        child: Text(AppTexts.login.toUpperCase()),
                      ),
                    ),
                    SizedBox(width: 10.0.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, SignupScreen.routeName),
                        child: Text(AppTexts.signup.toUpperCase()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}