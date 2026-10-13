import 'package:fit_store/common/preferences/preferences_manager.dart';
import 'package:fit_store/features/auth/presentation/bloc/email_auth_bloc/email_auth_bloc.dart';
import 'package:fit_store/features/auth/presentation/screens/login/widgets/remember_me_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import '../../../../../../common/widgets/buttons/primary_button.dart';
import '../../../../../../common/widgets/form/custom_form_field.dart';
import '../../../../../../navigation_menu.dart';
import '../../../../../../utils/constants/image_strings.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/constants/text_strings.dart';
import '../../../../../../utils/popups/full_screen_loader.dart';
import '../../../../../../utils/popups/loaders.dart';
import '../../../cubit/social_auth-bloc/social_auth_cubit.dart';
import '../../forget_password/forget_password_mail/forget_password_mail.dart';
import '../../signup/verify_email.dart';

class LoginFormWidget extends StatelessWidget {
  LoginFormWidget({super.key});

  final email = TextEditingController();
  final password = TextEditingController();
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EmailAuthBloc, EmailAuthState>(
          listener: (context, state) async {
            if (state is EmailAuthLoading) {
              FullScreenLoader.openLoadingDialog(
                'Logging your in....',
                AppImages.docerAnimation,
                context,
              );
            }

            if (state is EmailAuthFailure) {
              FullScreenLoader.stopLoading(context);
              Loaders.errorSnackBar(
                title: 'Error',
                message: state.errorMessage,
                context: context,
              );
            }

            if (state is EmailNotVerified) {
              FullScreenLoader.stopLoading(context);
              Loaders.warningSnackBar(
                title: 'Warning',
                message: 'You must verified your email',
                context: context,
              );
              Navigator.pushNamed(
                context,
                VerifyEmailScreen.routeName,
                arguments: email.text.trim(),
              );
            }

            if (state is EmailAuthSuccess) {
              await PreferencesManager().setBool('rememberMe', rememberMe);
              FullScreenLoader.stopLoading(context);
              Loaders.successSnackBar(
                title: 'Success',
                message: 'Your account has been login successfully!',
                context: context,
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                NavigationMenu.routeName,
                    (route) => false,
              );
            }
          },
        ),
        BlocListener<SocialAuthCubit, SocialAuthState>(
          listener: (context, state) async {
            if (state is EmailAuthLoading) {
              FullScreenLoader.openLoadingDialog(
                'Logging your in....',
                AppImages.docerAnimation,
                context,
              );
            }
            if (state is SocialAuthFailure) {
              Loaders.errorSnackBar(
                title: 'error',
                context: context,
                message: state.errorMessage,
              );
            }
            if (state is SocialAuthSuccess) {
              await PreferencesManager().setBool('rememberMe', rememberMe);
              FullScreenLoader.stopLoading(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                NavigationMenu.routeName,
                    (route) => false,
              );
            }
          },
        ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.xl.h),
        child: Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFormfieldWidget.withdownEar(
                label: AppTexts.email,
                controller: email,
                prefixIcon: const Icon(LineAwesomeIcons.user),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSizes.spaceBtwInputFields.h),
              CustomFormfieldWidget(
                label: AppTexts.password,
                controller: password,
                prefixIcon: const Icon(Icons.fingerprint),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                withdownEar: false,
              ),
              SizedBox(height: AppSizes.spaceBtwItems.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RememberMe(
                    valueChanged: (bool value) => rememberMe = value,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      ForgetPasswordMailScreen.routeName,
                    ),
                    child: const Text(AppTexts.forgetPassword),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.spaceBtwItems.h),
              BlocBuilder<EmailAuthBloc, EmailAuthState>(
                builder: (context, state) {
                  return PrimaryButton(
                    isLoading: state is EmailAuthLoading,
                    text: AppTexts.login.tr,
                    onPressed: () async {
                      if (_loginFormKey.currentState!.validate()) {
                        context.read<EmailAuthBloc>().add(
                          SignInWithEmailEvent(
                            email: email.text.trim(),
                            password: password.text.trim(),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}