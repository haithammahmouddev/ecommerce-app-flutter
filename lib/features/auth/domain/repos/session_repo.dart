import 'package:dartz/dartz.dart';

import '../../../../common/errors/failure.dart';

abstract class SessionRepo {
  Future<Either<Failure, void>> signOut();
}