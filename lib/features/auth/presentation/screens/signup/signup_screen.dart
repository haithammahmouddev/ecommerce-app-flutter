import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/di/injection_container.dart';
import '../../../../../common/widgets/buttons/clickable_richtext_widget.dart';
import '../../../../../common/widgets/form/form_header_widget.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../bloc/email_auth_bloc/email_auth_bloc.dart';
import '../login/login_screen.dart';
import 'widgets/signup_form_widget.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});
  static const routeName = '/signup-screen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<EmailAuthBloc>(),
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FormHeaderWidget(
                    image: AppImages.welcomeScreenImage,
                    title: AppTexts.signUpTitle,
                    subTitle: AppTexts.signUpSubTitle,
                    imageHeight: 0.1,
                  ),
                  SignUpFormWidget(),
                  Align(
                    alignment: Alignment.center,
                    child: ClickableRichTextWidget(
                      text1: AppTexts.alreadyHaveAnAccount,
                      text2: AppTexts.login,
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        LoginScreen.routeName,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}