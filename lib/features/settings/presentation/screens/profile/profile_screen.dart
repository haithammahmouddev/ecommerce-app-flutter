import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_store/features/settings/presentation/screens/profile/widgets/change_phone_num.dart';
import 'package:fit_store/features/settings/presentation/screens/profile/widgets/change_user_name.dart';
import 'package:fit_store/features/settings/presentation/screens/profile/widgets/profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/buttons/primary_button.dart';
import '../../../../../common/widgets/images/circular_image.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/popups/full_screen_loader.dart';
import '../../../../../utils/popups/loaders.dart';
import '../../../../auth/presentation/screens/login/login_screen.dart';
import '../../controllers/user_cubit/user_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const String routeName = '/profile-screen';

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state.userDataStatus == UserDataStatus.error) {
          Navigator.pop(context);
          Loaders.errorSnackBar(
            title: 'Operation Failed',
            context: context,
            message: state.errorMessage ?? 'Something went wrong.',
          );
        }
        if (state.userDataStatus == UserDataStatus.loading) {
          FullScreenLoader.popUpCircular(context);
        }

        if (state.userDataStatus == UserDataStatus.loaded) {
          Navigator.pop(context);
          Loaders.successSnackBar(
            context: context,
            message: 'The operation was completed successfully!',
            title: 'successfully!',
          );
        }
      },
      child: Scaffold(
        appBar: const AppBarCustom(
          showBackArrow: true,
          title: Text('Profile'),
          showActions: false,
          showSkipButton: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.defaultSpace),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      BlocBuilder<UserCubit, UserState>(
                        buildWhen: (previous, current) =>
                        previous.user?.profilePicture !=
                            current.user?.profilePicture,
                        builder: (context, state) {
                          final user = state.user;
                          return CircularImage(
                            image: user!.profilePicture,
                            isNetworkImage: true,
                            width: 110.w,
                            height: 120.h,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () async {
                          await context.read<UserCubit>().pickImage(
                            ImageSource.gallery,
                          );
                        },
                        child: const Text('Change Profile Picture'),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSizes.spaceBtwItems / 2),
                const Divider(),
                SizedBox(height: AppSizes.spaceBtwItems),

                const SectionHeading(
                  title: 'Profile Information',
                  showActionButton: false,
                ),
                SizedBox(height: AppSizes.spaceBtwItems),
                Column(
                  children: [
                    BlocBuilder<UserCubit, UserState>(
                      buildWhen: (previous, current) =>
                      previous.user?.fullName != current.user?.fullName,
                      builder: (context, state) {
                        final user = state.user;
                        return ProfileMenu(
                          title: 'Name',
                          value: user?.fullName ?? '-',
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return BlocProvider.value(
                                    value: context.read<UserCubit>(),
                                    child: ChangeName(),
                                  );
                                },
                              ),
                            );
                            if (result == true) {
                              context.read<UserCubit>().getUserData();
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: AppSizes.spaceBtwItems),
                    ProfileMenu(
                      title: 'E-mail',
                      value: context.read<UserCubit>().state.user?.email ?? '-',
                    ),
                    BlocBuilder<UserCubit, UserState>(
                      buildWhen: (previous, current) =>
                      previous.user?.phoneNumber !=
                          current.user?.phoneNumber,
                      builder: (context, state) {
                        final user = state.user;
                        return ProfileMenu(
                          title: 'Phone Number',
                          value: (user?.phoneNumber != null &&
                              user!.phoneNumber.isNotEmpty)
                              ? user.phoneNumber
                              : 'Enter Phone Number',
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return BlocProvider.value(
                                    value: context.read<UserCubit>(),
                                    child: ChangePhoneNum(),
                                  );
                                },
                              ),
                            );
                            if (result == true) {
                              context.read<UserCubit>().getUserData();
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.spaceBtwItems),
                const Divider(),
                SizedBox(height: AppSizes.spaceBtwItems),

                const SectionHeading(
                  title: 'Account',
                  showActionButton: false,
                ),
                SizedBox(height: AppSizes.spaceBtwItems),
                Column(
                  children: [
                    ProfileMenu(
                      title: 'Delete Account',
                      value: '',
                      onPressed: () => _showDeleteAccountDialog(context),
                    ),
                    ProfileMenu(
                      title: 'Log Out',
                      value: '',
                      onPressed: () => _showLogOutDialog(context),
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

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.red,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text('Are you sure you want to delete your account?'),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            PrimaryButton(
              isFullWidth: false,
              text: 'Yes',
              onPressed: () async {
                context.read<UserCubit>().deleteAccount(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Log Out',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              isFullWidth: false,
              text: 'Log Out',
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    LoginScreen.routeName,
                        (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}