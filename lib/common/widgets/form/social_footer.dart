import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../features/auth/presentation/cubit/social_auth-bloc/social_auth_cubit.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../buttons/clickable_richtext_widget.dart';
import '../buttons/social_button.dart';

class SocialFooter extends StatelessWidget {
  const SocialFooter({
    super.key,
    this.text1 = AppTexts.donotHaveAnAccount,
    this.text2 = AppTexts.signup,
    required this.onPressed,
  });

  final String text1;
  final String text2;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSizes.defaultSpace * 1.5,
        bottom: AppSizes.defaultSpace,
      ),
      child: Column(
        children: [
          BlocBuilder<SocialAuthCubit, SocialAuthState>(
            builder: (context, state) {
              return SocialButton(
                image: AppImages.googleLogo,
                background: AppColors.googleBackgroundColor,
                foreground: AppColors.googleForegroundColor,
                text: '${AppTexts.connectWith.tr} ${AppTexts.google.tr}',
                isLoading: state is SocialAuthLoading,
                onPressed: () {
                  context.read<SocialAuthCubit>().signInWithGoogle();
                },
              );
            },
          ),
          SizedBox(height: AppSizes.defaultSpace * 2),
          ClickableRichTextWidget(
            text1: text1.tr,
            text2: text2.tr,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}