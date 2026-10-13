import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repos/session_repo.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final SessionRepo sessionRepository;
  SessionCubit({required this.sessionRepository}) : super(SessionInitial());

  Future<void> SignOut() async {
    final result = await sessionRepository.signOut();

    result.fold(
      (failure) {
        emit(SessionError(message: failure.message));
      },
      (_) {
        emit(const Unauthenticated());
      },
    );
  }
}
