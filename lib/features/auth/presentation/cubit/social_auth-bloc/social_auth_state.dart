part of 'social_auth_cubit.dart';

@immutable
sealed class SocialAuthState {}

final class SocialAuthInitial extends SocialAuthState {}
class SocialAuthLoading extends SocialAuthState {}
class SocialAuthSuccess extends SocialAuthState {
  final UserEntity user;
  SocialAuthSuccess({required this.user});
}
class SocialAuthFailure extends SocialAuthState {
  final String errorMessage;
  SocialAuthFailure({required this.errorMessage});
}
