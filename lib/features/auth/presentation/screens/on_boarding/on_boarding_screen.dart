import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../../utils/constants/colors.dart';
import 'onboarding_cubit/onboarding_cubit.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});
 static const routeName = '/onboarding-screen';
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnBoardingCubit(),
      child: Builder(
        builder: (context) {
          final controller = context.read<OnBoardingCubit>();
          return Scaffold(
            body: Stack(
              alignment: Alignment.center,
              children: [
                LiquidSwipe(
                  pages: controller.pages,
                  enableSideReveal: true,
                  liquidController: controller.controller,
                  onPageChangeCallback: controller.onPageChangedCallback,
                  slideIconWidget: const Icon(Icons.arrow_back_ios),
                  waveType: WaveType.circularReveal,
                ),
                Positioned(
                  bottom: 60.0,
                  child: OutlinedButton(
                    onPressed: () async{
                     await controller.animateToNextSlideWithLocalStorage(context);
                      },
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.black26),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      foregroundColor: Colors.white,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: const BoxDecoration(color: AppColors.black, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: TextButton(onPressed: () => controller.skip(), child: const Text("Skip", style: TextStyle(color: Colors.grey))),
                ),
                BlocBuilder<OnBoardingCubit, OnBoardingState>(
                  builder: (context, state) {
                    return Positioned(
                      bottom: 10,
                      child: AnimatedSmoothIndicator(
                        count: 3,
                        activeIndex: state.currentPage,
                        effect: const ExpandingDotsEffect(activeDotColor: Color(0xff272727)),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}