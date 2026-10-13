import 'package:dartz/dartz.dart';
import 'package:fit_store/common/errors/failure.dart';
import '../../../settings/domain/entities/user_entity.dart';

abstract interface class EmailAuthRepo {
  Future<Either<Failure, UserEntity>>
  signUp({required String userName,
    required String phoneNumber,
    required String email, required String password});

  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

}