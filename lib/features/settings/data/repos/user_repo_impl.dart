import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_store/common/errors/failure.dart';
import 'package:fit_store/common/network/firebase/database_services.dart';
import 'package:fit_store/features/settings/domain/repos/user_repo.dart';
import '../../../../common/errors/exceptions.dart';
import '../../../../common/network/firebase/auth_client.dart';
import '../../../../common/network/firebase/storage_service.dart';
import '../../../../common/local_storage/loacal_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

class UserRepoImpl implements UserRepo{
  final DatabaseServices _databaseServices;
  final AuthClient _authClient;
  final StorageService _storageService;
  UserRepoImpl({required this._databaseServices, required this._authClient, required this._storageService});
  Future<Either<Failure, UserEntity>> getUserData() async {
    try {
      final UserModel? userData = LocalStorageService.userRepo.getData();
      if(userData == null) return right(UserEntity.empty);
      return right(userData.toEntity());
    } on ServerException catch (e) {
      return left(ServerFailure(e.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
  Future<Either<Failure, UserEntity>> updateUserName({required String fullName}) async {
    try {
      await _databaseServices.updateData(
          path: 'users',
          docId: FirebaseAuth.instance.currentUser!.uid,
          data: {
            'FullName': fullName,
          }
      );
      await LocalStorageService.userRepo.updateData((currentUser) {
        return currentUser.copyWith(fullName: fullName);
      });
      final UserModel? userData = LocalStorageService.userRepo.getData();
      if(userData == null) return right(UserEntity.empty);
      return right(userData.toEntity());
    } on ServerException catch (e) {
      return left(ServerFailure(e.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
  Future<Either<Failure, UserEntity>> updatePhoneNumber({required String phoneNum}) async {
    try {
      await _databaseServices.updateData(
          path: 'users',
          docId: FirebaseAuth.instance.currentUser!.uid,
          data: {
            'PhoneNumber': phoneNum,
          }
      );
      await LocalStorageService.userRepo.updateData((currentUser) {
        return currentUser.copyWith(phoneNumber: phoneNum);
      });
      final UserModel? userData = LocalStorageService.userRepo.getData();
      if(userData == null) return right(UserEntity.empty);
      return right(userData.toEntity());
    } on ServerException catch (e) {
      return left(ServerFailure(e.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
  Future<Either<Failure, UserEntity>> uploadImagePic({required File file}) async {
    try {
      final String imagePic = await _storageService.uploadFile(file: file, path: 'image_profile');
      await _databaseServices.updateData(
        path: 'users',
        docId: FirebaseAuth.instance.currentUser!.uid,
        data: {
          'ProfilePicture': imagePic,
        },
      );
      await LocalStorageService.userRepo.updateData((currentUser) {
        return currentUser.copyWith(profilePicture: imagePic);
      });
      final UserModel? userData = LocalStorageService.userRepo.getData();
      if(userData == null) return right(UserEntity.empty);
      return right(userData.toEntity());
    } on ServerException catch (e) {
      return left(ServerFailure(e.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _databaseServices.deleteData(path: 'users',
          docId: FirebaseAuth.instance.currentUser!.uid);
      await _authClient.deleteAccount();
      await LocalStorageService.userRepo.clearData();
      return const Right(null);
    } on ServerException catch (e) {
      return left(ServerFailure(e.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
  Future<Either<Failure, void>> reAuthenticateEmailAndPassword({required String email, required String password,}) async {
    try {
      await _authClient.reAuthenticateWithEmailAndPassword(email: email,
          password: password);
      return const Right(null);
    } on ServerException catch (e) {
      return left(ServerFailure(e.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}