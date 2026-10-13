import 'package:fit_store/features/auth/domain/repos/social_auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../../../../settings/domain/entities/user_entity.dart';
part 'social_auth_state.dart';

class SocialAuthCubit extends Cubit<SocialAuthState> {
  final SocialAuthRepo _socialAuthRepo;
  SocialAuthCubit({required this._socialAuthRepo}) : super(SocialAuthInitial());

  Future<void> signInWithGoogle() async{
    emit(SocialAuthLoading());
    final result = await _socialAuthRepo.signInWithGoogle();
    result.fold((failure){
      emit(SocialAuthFailure(errorMessage: failure.message));
    }, (success){
      emit(SocialAuthSuccess(user: success));
    });
  }
}
