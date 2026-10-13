import 'package:dartz/dartz.dart';
import 'package:fit_store/common/errors/exceptions.dart';
import 'package:fit_store/common/errors/failure.dart';
import '../../domain/repos/reset_password_repo.dart';
import '../data_source/reset_password_datasource.dart';

class ResetPasswordRepoImple implements ResetPasswordRepo{
  final ResetPasswordDatasource _resetPasswordDatasource;
  ResetPasswordRepoImple({required this._resetPasswordDatasource});

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email}) async{
   try{
     await _resetPasswordDatasource.sendPasswordResetEmail(email: email);
     return const Right(null);
   }on AuthException catch(e){
     return left(AuthFailure(e.toString()));
   }on ServerException catch(e){
     return left(ServerFailure(e.toString()));
   }catch(e){
     return left(AuthFailure(e.toString()));
   }
  }
}