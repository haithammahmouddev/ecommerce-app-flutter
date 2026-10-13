import 'package:fit_store/features/auth/presentation/screens/splash_screen/splash_screen.dart';
import 'package:fit_store/routes/app_routes.dart';
import 'package:fit_store/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'common/navigation/navigation_service.dart';
import 'features/settings/presentation/controllers/theme/theme_controller_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Fit Store',
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          themeMode: themeController.themeMode,
          theme: TAppTheme.lightTheme,
          darkTheme: TAppTheme.darkTheme,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          initialRoute: SplashScreen.routeName,
        );
      },
    );
  }
}