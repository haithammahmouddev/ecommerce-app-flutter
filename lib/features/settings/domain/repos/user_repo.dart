import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:fit_store/common/errors/failure.dart';
import '../entities/user_entity.dart';

abstract class UserRepo {
  Future<Either<Failure, UserEntity>> getUserData();
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, UserEntity>> updateUserName({required String fullName});
  Future<Either<Failure, UserEntity>> updatePhoneNumber({required String phoneNum});
  Future<Either<Failure, UserEntity>> uploadImagePic({required File file});
  Future<Either<Failure, void>> reAuthenticateEmailAndPassword({
    required String email,
    required String password,
  });
}