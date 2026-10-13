import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fit_store/features/auth/domain/repos/reset_password_repo.dart';
part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordRepo _resetPasswordRepo;
  ResetPasswordCubit({required this._resetPasswordRepo}) : super(ResetPasswordInitial());

  sendPasswordResetEmail({required String email}) async{
    emit(ResetPasswordLoading());
    final result = await _resetPasswordRepo.sendPasswordResetEmail(email: email);
    result.fold((failure){
      emit(ResetPasswordFailure(errorMessage: failure.message));
    }, (success){
      emit(ResetPasswordSuccess());
    });
  }
}
