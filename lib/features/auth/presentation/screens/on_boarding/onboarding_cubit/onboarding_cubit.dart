
import 'package:equatable/equatable.dart';
import 'package:fit_store/common/preferences/preferences_manager.dart';
import 'package:fit_store/features/auth/presentation/models/model_on_boarding.dart';
import 'package:fit_store/features/auth/presentation/screens/on_boarding/widgets/on_boarding_page_widget.dart';
import 'package:fit_store/features/auth/presentation/screens/welcome/welcome_screen.dart';
import 'package:fit_store/utils/constants/colors.dart';
import 'package:fit_store/utils/constants/image_strings.dart';
import 'package:fit_store/utils/constants/text_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_swipe/PageHelpers/LiquidController.dart';

 part 'onboarding_state.dart';

class OnBoardingCubit extends Cubit<OnBoardingState> {
  OnBoardingCubit() : super(const OnBoardingState());

  final LiquidController controller = LiquidController();

   skip() => controller.jumpToPage(page: 2);

  animateToNextSlideWithLocalStorage(BuildContext context) async{
    if (controller.currentPage == 2) {
     await PreferencesManager().setBool('is_first_time', true);
       Navigator.pushReplacementNamed(context, WelcomeScreen.routeName);
     } else {
      controller.animateToPage(page: controller.currentPage + 1);
    }
  }

  onPageChangedCallback(int activePageIndex) =>
      emit(state.copyWith(currentPage: activePageIndex));


  final pages = [
    OnBoardingPageWidget(
      model: OnBoardingModel(
        image: AppImages.onBoardingImage1,
        title: AppTexts.onBoardingTitle1,
        subTitle: AppTexts.onBoardingSubTitle1,
        counterText: AppTexts.onBoardingCounter1,
        bgColor: AppColors.onBoardingPage1Color,
      ),
    ),
    OnBoardingPageWidget(
      model: OnBoardingModel(
        image: AppImages.onBoardingImage2,
        title: AppTexts.onBoardingTitle2,
        subTitle: AppTexts.onBoardingSubTitle2,
        counterText: AppTexts.onBoardingCounter2,
        bgColor: AppColors.onBoardingPage2Color,
      ),
    ),
    OnBoardingPageWidget(
      model: OnBoardingModel(
        image: AppImages.onBoardingImage3,
        title: AppTexts.onBoardingTitle3,
        subTitle: AppTexts.onBoardingSubTitle3,
        counterText: AppTexts.onBoardingCounter3,
        bgColor: AppColors.onBoardingPage3Color,
      ),
    ),
  ];
}