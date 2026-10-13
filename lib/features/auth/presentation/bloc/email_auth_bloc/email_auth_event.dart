part of 'email_auth_bloc.dart';

@immutable
sealed class EmailAuthEvent {}

class SignUpWithEmailEvent extends EmailAuthEvent {
  final String userName;
  final String email;
  final String phoneNumber;
  final String password;
  SignUpWithEmailEvent({
    required this.userName,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });
}

class SignInWithEmailEvent extends EmailAuthEvent {
  final String email;
  final String password;
  SignInWithEmailEvent({required this.email, required this.password});
}
