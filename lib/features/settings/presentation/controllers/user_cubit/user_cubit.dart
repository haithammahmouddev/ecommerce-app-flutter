import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_store/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../utils/popups/full_screen_loader.dart';
import '../../../../../utils/popups/loaders.dart';
import '../../../../auth/presentation/screens/login/login_screen.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repos/user_repo.dart';
import '../../screens/profile/re_authenticate_user_login_form.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepo _userRepoImpl;
  UserCubit({required this._userRepoImpl}) : super(UserState()) {
    getUserData();
  }

  Future<void> getUserData() async {
    final result = await _userRepoImpl.getUserData();
    result.fold(
      (error) {
        emit(
          state.copyWith(
            errorMessage: error.message,
            userDataStatus: UserDataStatus.error,
          ),
        );
      },
      (freshUser) async {
        emit(
          state.copyWith(
            user: freshUser,
            userDataStatus: UserDataStatus.loaded,
          ),
        );
      },
    );
  }

  Future<void> updateUserName({required String fullName}) async {
    emit(state.copyWith(userDataStatus: UserDataStatus.loading));

    final result = await _userRepoImpl.updateUserName(fullName: fullName);

    result.fold(
      (error) {
        emit(
          state.copyWith(
            errorMessage: error.message,
            userDataStatus: UserDataStatus.error,
          ),
        );
      },
      (userData) async {
        emit(
          state.copyWith(user: userData, userDataStatus: UserDataStatus.loaded),
        );
      },
    );
  }

  Future<void> updatePhoneNumber({required String phoneNum}) async {
    emit(state.copyWith(userDataStatus: UserDataStatus.loading));

    final result = await _userRepoImpl.updatePhoneNumber(phoneNum: phoneNum);

    result.fold(
      (error) {
        emit(
          state.copyWith(
            errorMessage: error.message,
            userDataStatus: UserDataStatus.error,
          ),
        );
      },
      (userData) async {
        emit(
          state.copyWith(user: userData, userDataStatus: UserDataStatus.loaded),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image == null) return;

    emit(state.copyWith(userDataStatus: UserDataStatus.loading));

    final result = await _userRepoImpl.uploadImagePic(file: File(image.path));

    result.fold(
      (error) {
        emit(
          state.copyWith(
            userDataStatus: UserDataStatus.error,
            errorMessage: error.message,
          ),
        );
      },
      (userData) async {
        emit(
          state.copyWith(user: userData, userDataStatus: UserDataStatus.loaded),
        );
      },
    );
  }

  Future<void> deleteAccount(BuildContext context) async {
    FullScreenLoader.openLoadingDialog(
      'Processing...',
      AppImages.docerAnimation,
      context,
    );

    final currentUser = FirebaseAuth.instance.currentUser;
    final String provider = currentUser!.providerData.isNotEmpty
        ? currentUser.providerData.first.providerId
        : '';

    if (provider.isEmpty) {
      FullScreenLoader.stopLoading(context);
      return;
    }

    if (provider == 'google.com') {
      final result = await _userRepoImpl.deleteAccount();
      result.fold(
        (error) {
          FullScreenLoader.stopLoading(context);
          emit(
            state.copyWith(
              errorMessage: error.message,
              userDataStatus: UserDataStatus.error,
            ),
          );
          return;
        },
        (_) {
          if (!context.mounted) return;
          FullScreenLoader.stopLoading(context);

          Navigator.pushNamedAndRemoveUntil(
            context,
            LoginScreen.routeName,
            (_) => false,
          );
        },
      );
    } else if (provider == 'password') {
      if (!context.mounted) return;
      FullScreenLoader.stopLoading(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<UserCubit>(),
            child: const ReAuthLoginForm(),
          ),
        ),
      );
    }
  }

  Future<void> reAuthenticateEmailAndPasswordUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    FullScreenLoader.openLoadingDialog(
      'Processing...',
      AppImages.docerAnimation,
      context,
    );

    final result = await _userRepoImpl.reAuthenticateEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold(
      (error) {
        FullScreenLoader.stopLoading(context);
        Loaders.errorSnackBar(
          title: 'Error',
          context: context,
          message: error.message,
        );
      },
      (_) async {
        final result = await _userRepoImpl.deleteAccount();
        result.fold(
          (error) {
            FullScreenLoader.stopLoading(context);
            emit(
              state.copyWith(
                errorMessage: error.message,
                userDataStatus: UserDataStatus.error,
              ),
            );
            return;
          },
          (_) {
            if (!context.mounted) return;
            FullScreenLoader.stopLoading(context);

            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginScreen.routeName,
              (_) => false,
            );
          },
        );
      },
    );
  }
}
