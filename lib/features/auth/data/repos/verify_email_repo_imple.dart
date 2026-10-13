import 'package:dartz/dartz.dart';
import 'package:fit_store/common/errors/failure.dart';
import 'package:fit_store/features/auth/data/data_source/verify_email_datasource.dart';
import '../../../../common/errors/exceptions.dart';
import '../../domain/repos/verify_email_repo.dart';

class VerifyEmailRepoImple implements VerifyEmailRepo{
  final VerifyEmailDatasource _verifyEmailDatasource;
  VerifyEmailRepoImple({required this._verifyEmailDatasource});
  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try{
      await _verifyEmailDatasource.sendEmailVerification();
      return const Right(null);
    }on AuthException catch (e){
      return left(AuthFailure(e.toString()));
    } on ServerException catch (e){
      return  left(ServerFailure(e.toString()));
    }catch(e){
      return  left(ServerFailure(e.toString()));
    }
  }
}