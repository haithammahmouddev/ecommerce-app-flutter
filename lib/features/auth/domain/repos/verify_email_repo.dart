import 'package:dartz/dartz.dart';
import 'package:fit_store/common/errors/failure.dart';

abstract interface class VerifyEmailRepo {
  Future<Either<Failure, void>> sendEmailVerification();
}