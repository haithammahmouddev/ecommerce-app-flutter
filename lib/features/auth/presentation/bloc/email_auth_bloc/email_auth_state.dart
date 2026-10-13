part of 'email_auth_bloc.dart';

@immutable
sealed class EmailAuthState {}

class EmailAuthInitial extends EmailAuthState {}

class EmailAuthLoading extends EmailAuthState {}

class EmailAuthSuccess extends EmailAuthState {}

class EmailNotVerified extends EmailAuthState {}

class EmailAuthFailure extends EmailAuthState {
  final String errorMessage;
  EmailAuthFailure({required this.errorMessage});
}
