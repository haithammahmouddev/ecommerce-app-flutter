part of 'verify_email_cubit.dart';

enum VerifyEmailStatus {
  initial,
  checkLoading,
  resendLoading,
  sent,
  verified,
  failure,
}
@immutable
class VerifyEmailState extends Equatable {
  final VerifyEmailStatus status;
  final String? message;

  const VerifyEmailState({
    this.status = VerifyEmailStatus.initial,
    this.message,
  });

  VerifyEmailState copyWith({
    VerifyEmailStatus? status,
    String? message,
  }) {
    return VerifyEmailState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}