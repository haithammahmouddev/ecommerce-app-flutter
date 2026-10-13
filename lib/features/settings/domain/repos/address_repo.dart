import 'package:dartz/dartz.dart';
import '../../../../common/errors/failure.dart';
import '../entities/address_entity.dart';

abstract class AddressRepo {
  Future<Either<Failure, List<AddressEntity>>> fetchUserAddresses();
  Future<Either<Failure, String>> addAddress(AddressEntity address);
  Future<Either<Failure, void>> updateSelectedField(String addressId, bool selected);
}