import 'package:dartz/dartz.dart';
import '../../../../common/errors/exceptions.dart';
import '../../../../common/errors/failure.dart';
import '../../domain/repos/session_repo.dart';
import '../data_source/session_datasource.dart';

class SessionRepositoryImpl implements SessionRepo {
  final SessionDataSource _sessionDataSource;

  SessionRepositoryImpl({required this._sessionDataSource});


  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _sessionDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

}