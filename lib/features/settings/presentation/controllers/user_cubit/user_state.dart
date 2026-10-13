part of 'user_cubit.dart';

enum UserDataStatus {
  loading,
  loaded,
  error,
}

class UserState extends Equatable {
  final UserEntity? user;
  final UserDataStatus userDataStatus;
  final String? errorMessage;

  const UserState({
    this.user,
    this.userDataStatus = UserDataStatus.loading,
    this.errorMessage,
   });

  UserState copyWith({
    UserEntity? user,
    UserDataStatus? userDataStatus,
    String? errorMessage,
    XFile? selectedImage,
    bool? clearError,
  }) {
    return UserState(
      user: user ?? this.user,
      userDataStatus: userDataStatus ?? this.userDataStatus,
      errorMessage: errorMessage ?? this.errorMessage,
     );
  }

  @override
  List<Object?> get props => [
    user, errorMessage, userDataStatus];
}