import 'package:fit_store/common/widgets/appbar/appbar.dart';
import 'package:fit_store/features/auth/presentation/cubit/verify_email_cubit/verify_email_cubit.dart';
import 'package:fit_store/features/auth/presentation/screens/login/login_screen.dart';
import 'package:fit_store/utils/constants/image_strings.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:fit_store/utils/constants/text_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/di/injection_container.dart';
import '../../../../../common/widgets/success_screen/success_screen.dart';
import '../../../../../utils/popups/loaders.dart';
import '../../cubit/session_cubit/session_cubit.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, required this.email});
  final String email;
  static const routeName = '/verify-email-screen';

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
              sl<VerifyEmailCubit>()..sendVerificationEmail(),
            ),
            BlocProvider(create: (context) => sl<SessionCubit>()),
          ],
          child: Builder(
            builder: (context) {
              return MultiBlocListener(
                listeners: [
                  BlocListener<VerifyEmailCubit, VerifyEmailState>(
                    listener: (context, state) {
                      if (state.status == VerifyEmailStatus.failure) {
                        Loaders.errorSnackBar(
                          title: 'On Snap!',
                          context: context,
                          message: state.message!,
                        );
                      }
                      if (state.status == VerifyEmailStatus.sent) {
                        Loaders.successSnackBar(
                          title: 'sent',
                          context: context,
                          message:
                          state.message ??
                              'Verification email sent successfully!',
                        );
                      }
                      if (state.status == VerifyEmailStatus.verified) {
                        Navigator.pushReplacementNamed(
                          context,
                          SuccessScreen.routeName,
                          arguments: {
                            'image': AppImages.successfullyRegisterAnimation,
                            'title': AppTexts.yourAccountCreatedTitle,
                            'subTitle': AppTexts.yourAccountCreatedSubTitle,
                            'onPressed': (successContext) {
                              Navigator.pushNamedAndRemoveUntil(
                                successContext,
                                LoginScreen.routeName,
                                    (route) => false,
                              );
                            },
                          },
                        );
                      }
                    },
                  ),
                  BlocListener<SessionCubit, SessionState>(
                    listener: (context, state) {
                      if (state is Unauthenticated) {
                        Loaders.warningSnackBar(
                          title: 'Session Expired',
                          message:
                          'You have been logged out. Please log in again.',
                          context: context,
                        );
                        Navigator.pushReplacementNamed(
                          context,
                          LoginScreen.routeName,
                        );
                      }
                      if (state is SessionError) {
                        Loaders.errorSnackBar(
                          title: 'On Snap!',
                          context: context,
                          message: state.message,
                        );
                      }
                    },
                  ),
                ],
                child: Builder(
                  builder: (context) {
                    final controller = context.read<VerifyEmailCubit>();
                    return Scaffold(
                      appBar: AppBarCustom(
                        actions: [
                          IconButton(
                            onPressed: () {
                              context.read<SessionCubit>().SignOut();
                            },
                            icon: const Icon(CupertinoIcons.clear),
                          ),
                        ],
                        showActions: true,
                        showSkipButton: false,
                      ),
                      body: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.defaultSpace),
                          child: Column(
                            children: [
                              Image(
                                image: const AssetImage(
                                  AppImages.deliveredEmailIllustration,
                                ),
                                width: 0.6.sw,
                              ),
                              SizedBox(height: AppSizes.spaceBtwSections),
                              Text(
                                AppTexts.confirmEmail,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppSizes.spaceBtwItems),
                              Text(
                                email,
                                style: Theme.of(context).textTheme.labelLarge,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppSizes.spaceBtwItems),
                              Text(
                                AppTexts.confirmEmailSubTitle,
                                style: Theme.of(context).textTheme.labelMedium,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppSizes.spaceBtwSections),
                              SizedBox(
                                width: double.infinity,
                                child: BlocSelector<
                                    VerifyEmailCubit,
                                    VerifyEmailState,
                                    bool
                                >(
                                  selector: (state) =>
                                  state.status ==
                                      VerifyEmailStatus.checkLoading,
                                  builder: (context, isLoading) {
                                    return ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                        controller
                                            .checkEmailVerificationStatus(
                                          context,
                                          controller,
                                        );
                                      },
                                      child: isLoading
                                          ? SizedBox(
                                        height: 20.r,
                                        width: 20.r,
                                        child:
                                        const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : const Text(AppTexts.Continue),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: AppSizes.spaceBtwItems),
                              SizedBox(
                                width: double.infinity,
                                child: BlocSelector<
                                    VerifyEmailCubit,
                                    VerifyEmailState,
                                    bool
                                >(
                                  selector: (state) =>
                                  state.status ==
                                      VerifyEmailStatus.resendLoading,
                                  builder: (context, isLoading) {
                                    return TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                        controller
                                            .resendVerificationEmail();
                                      },
                                      child: isLoading
                                          ? SizedBox(
                                        height: 20.r,
                                        width: 20.r,
                                        child:
                                        const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : const Text(AppTexts.resendEmail),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}