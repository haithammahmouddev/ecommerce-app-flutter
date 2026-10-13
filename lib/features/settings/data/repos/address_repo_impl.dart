import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_store/common/errors/failure.dart';
import 'package:fit_store/common/local_storage/loacal_storage_service.dart';
import 'package:fit_store/features/settings/domain/repos/address_repo.dart';
import '../../domain/entities/address_entity.dart';
import '../models/address_model.dart';

class AddressRepoImpl implements AddressRepo {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Future<Either<Failure, List<AddressEntity>>> fetchUserAddresses() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return left(
          const ServerFailure(
            'Unable to find user information. Try again in few minutes.',
          ),
        );
      }
      final result = await _db
          .collection('users')
          .doc(userId)
          .collection('Addresses')
          .get();

      final List<AddressModel> addressList = result.docs
          .map(
            (documentSnapshot) => AddressModel.fromSnapshot(documentSnapshot),
      )
          .toList();
      await LocalStorageService.addressRepo.saveData(addressList);

      return right(addressList.map((e) => e.toEntity()).toList());
    } on FirebaseException catch (e) {
      return left(
        ServerFailure(e.message ?? 'حدث خطأ أثناء جلب البيانات من الخادم.'),
      );
    } catch (e) {
      return left(
        const ServerFailure(
          'Something went wrong while fetching Address Information. Try again later',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateSelectedField(
      String addressId,
      bool selected,
      ) async {
    try {
      final userId = _auth.currentUser?.uid ?? '';

      if (userId.isEmpty) {
        return left(
          const ServerFailure(
            'Unable to find user information. Try again in few minutes.',
          ),
        );
      }

      await _db
          .collection('users')
          .doc(userId)
          .collection('Addresses')
          .doc(addressId)
          .update({'SelectedAddress': selected});

      return right(null);
    } on FirebaseException catch (e) {
      return left(
        ServerFailure(e.message ?? 'Unable to update your address selection.'),
      );
    } catch (e) {
      return left(
        const ServerFailure(
          'Unable to update your address selection. Try again later',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> addAddress(AddressEntity address) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return left(
          const ServerFailure('Unable to find user information. Try again.'),
        );
      }


      final docRef =
      _db.collection('users').doc(userId).collection('Addresses').doc();

      final addressModel =
      AddressModel.fromEntity(address.copyWith(id: docRef.id));

      await docRef.set(addressModel.toJson());
      return right(docRef.id);
    } on FirebaseException catch (e) {
      return left(ServerFailure(e.message ?? 'حدث خطأ أثناء حفظ العنوان.'));
    } catch (e) {
      return left(
        const ServerFailure(
          'Something went wrong while saving Address Information. Try again later',
        ),
      );
    }
  }
}