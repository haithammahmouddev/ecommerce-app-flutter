import 'package:fit_store/features/auth/presentation/cubit/reset_password_cubit/reset_password_cubit.dart';
import 'package:fit_store/features/auth/presentation/screens/forget_password/forget_password_mail/reset_password_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../common/di/injection_container.dart';
import '../../../../../../common/widgets/buttons/primary_button.dart';
import '../../../../../../common/widgets/form/form_header_widget.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/image_strings.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/constants/text_strings.dart';
import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../../../utils/popups/loaders.dart';

class ForgetPasswordMailScreen extends StatefulWidget {
  const ForgetPasswordMailScreen({super.key});
  static const routeName = '/forget-password-email-screen';

  @override
  State<ForgetPasswordMailScreen> createState() =>
      _ForgetPasswordMailScreenState();
}

class _ForgetPasswordMailScreenState extends State<ForgetPasswordMailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController email;

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
  }

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return BlocProvider(
      create: (context) => sl<ResetPasswordCubit>(),
      child: Builder(
        builder: (context) {
          return BlocListener<ResetPasswordCubit, ResetPasswordState>(
            listener: (context, state) {
              if (state is ResetPasswordFailure) {
                Loaders.errorSnackBar(
                  title: 'error',
                  context: context,
                  message: state.errorMessage,
                );
              }
              if (state is ResetPasswordSuccess) {
                Loaders.successSnackBar(
                  title: 'Email sent',
                  context: context,
                  message: 'Email link sent to Reset your Password',
                );

                Navigator.pushNamed(
                  context,
                  ResetPasswordScreen.routeName,
                  arguments: email.text.trim(),
                );
              }
            },
            child: SafeArea(
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(AppSizes.defaultSpace),
                    child: Column(
                      children: [
                        SizedBox(height: AppSizes.defaultSpace * 4),
                        FormHeaderWidget(
                          imageColor: dark
                              ? AppColors.primary
                              : AppColors.secondary,
                          image: AppImages.forgetPasswordImage,
                          title: AppTexts.forgetPassword,
                          subTitle: AppTexts.forgetPasswordSubTitle,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          heightBetween: 30.0.h,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSizes.xl),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: email,
                                validator: ((value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );

                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                }),
                                decoration: const InputDecoration(
                                  label: Text(AppTexts.email),
                                  hintText: AppTexts.email,
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                              ),
                              SizedBox(height: 20.0.h),
                              SizedBox(
                                width: double.infinity,
                                child: BlocBuilder<
                                    ResetPasswordCubit,
                                    ResetPasswordState
                                >(
                                  builder: (context, state) {
                                    return PrimaryButton(
                                      isLoading:
                                      state is ResetPasswordLoading,
                                      text: 'Next',
                                      onPressed: () async {
                                        if (_formKey.currentState!
                                            .validate()) {
                                          context
                                              .read<ResetPasswordCubit>()
                                              .sendPasswordResetEmail(
                                            email: email.text.trim(),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}