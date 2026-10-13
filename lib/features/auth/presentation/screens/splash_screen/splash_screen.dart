import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_store/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import '../../../../../common/preferences/preferences_manager.dart';
import '../../../../../navigation_menu.dart';
import '../login/login_screen.dart';
import '../on_boarding/on_boarding_screen.dart';
import '../signup/verify_email.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = '/splash-screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    screenRedirect(context);
    super.initState();
  }

  screenRedirect(BuildContext context) async {
    await Future.delayed(Duration(seconds: 2));
    final bool isFirstTime =
        PreferencesManager().getBool('is_first_time') ?? false;
    final user = FirebaseAuth.instance.currentUser;
    final bool rememberMe = PreferencesManager().getBool('rememberMe') ?? false;

    if (user != null) {
      if (!rememberMe) {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        return;
      }

      if (user.emailVerified) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          NavigationMenu.routeName,
          (route) => false,
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          VerifyEmailScreen.routeName,
          arguments: user.email,
        );
      }
    } else {
      if (!isFirstTime) {
        Navigator.pushReplacementNamed(context, OnBoardingScreen.routeName);
      } else {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = HelperFunctions.isDarkMode(context);
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image(
              image: AssetImage(
                !isDark
                    ? 'assets/logo/t-store-splash-logo-black.png'
                    : 'assets/logo/t-store-splash-logo-white.png',
              ),
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
