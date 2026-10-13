import 'package:dartz/dartz.dart';
import 'package:fit_store/common/errors/exceptions.dart';
import 'package:fit_store/common/errors/failure.dart';
import 'package:fit_store/features/auth/data/data_source/email_auth_datasource.dart';
import '../../../../common/network/firebase/auth_client.dart';
import '../../../../common/network/firebase/database_services.dart';
import '../../../../common/local_storage/loacal_storage_service.dart';
import '../../../settings/data/models/user_model.dart';
import '../../../settings/domain/entities/user_entity.dart';
import '../../domain/repos/email_auth_repo.dart';

class EmailAuthRepoImple implements EmailAuthRepo {
  final EmailAuthDatasource _emailAuthDatasource;
  final DatabaseServices _databaseServices;
  final AuthClient _authClient;

  EmailAuthRepoImple({
    required EmailAuthDatasource emailAuthDatasource,
    required DatabaseServices databaseServices, required this._authClient,
  })  : _emailAuthDatasource = emailAuthDatasource,
        _databaseServices = databaseServices;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserModel user = await _emailAuthDatasource.login(
        email: email,
        password: password,
      );
       final bool isVerified = await _authClient.isEmailVerified();
      final userFromServer = await _databaseServices.getData(path: 'users',
          docId: user.id);
      final UserModel userModel = UserModel.fromJson(userFromServer as Map<String, dynamic>);
      if(isVerified){
        await LocalStorageService.userRepo.saveData(userModel);
      }
      return right(userModel.toEntity());
    } on AuthException catch (e) {
      return left(AuthFailure(e.toString()));
    } on ServerException catch (e) {
      return left(ServerFailure(e.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String userName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    try {
      final UserModel user = await _emailAuthDatasource.signUp(
        userName: userName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
     await _databaseServices.setData(path: 'users',
         docId: user.id, data: user.toJson());
      return right(user.toEntity());
    } on AuthException catch (e) {
      return left(AuthFailure(e.toString()));
    } on ServerException catch (e) {
      return left(ServerFailure(e.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}