import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../../common/errors/failure.dart';
import '../../../../common/local_storage/loacal_storage_service.dart';
import '../models/order_model.dart';
import '../../../auth/domain/entities/order_entity.dart';
import '../../domain/repos/order_repo.dart';
import '../../../../utils/constants/enums.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<Either<Failure, List<OrderEntity>>> fetchUserOrders() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        throw 'Unable to find user information. Try again in few minutes.';
      }

      final result =
      await _db.collection('users').doc(userId).collection('Orders').get();
      final List<OrderModel> ordersList = result.docs
          .map((documentSnapshot) => OrderModel.fromSnapshot(documentSnapshot))
          .toList();

      final List<OrderModel> activeOrders = [];
      for (var order in ordersList) {
        if (order.status == OrderStatus.delivered) {
          await _db
              .collection('users')
              .doc(userId)
              .collection('Orders')
              .doc(order.id)
              .delete();
        } else {
          activeOrders.add(order);
        }
      }

      await LocalStorageService.ordersRepo.saveData(activeOrders);

      final List<OrderEntity> ordersEntity =
      activeOrders.map((e) => e.toEntity()).toList();
      return right(ordersEntity);
    } catch (e) {
      final cachedOrders = LocalStorageService.ordersRepo.getData();
      if (cachedOrders != null && cachedOrders.isNotEmpty) {
        final activeCached = cachedOrders
            .where((o) => o.status != OrderStatus.delivered)
            .toList();
        return right(activeCached.map((e) => e.toEntity()).toList());
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<OrderEntity>>> fetchUserOrdersStream() async* {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        yield left(const ServerFailure(
            'Unable to find user information. Try again in few minutes.'));
        return;
      }

      final stream =
      _db.collection('users').doc(userId).collection('Orders').snapshots();

      await for (final snapshot in stream) {
        final List<OrderModel> ordersList = snapshot.docs
            .map((documentSnapshot) =>
            OrderModel.fromSnapshot(documentSnapshot))
            .toList();

        final List<OrderModel> activeOrders = [];
        for (var order in ordersList) {
          if (order.status == OrderStatus.delivered) {
            await _db
                .collection('users')
                .doc(userId)
                .collection('Orders')
                .doc(order.id)
                .delete();
          } else {
            activeOrders.add(order);
          }
        }

        await LocalStorageService.ordersRepo.saveData(activeOrders);

        final List<OrderEntity> ordersEntity =
        activeOrders.map((e) => e.toEntity()).toList();
        yield right(ordersEntity);
      }
    } catch (e) {
      final cachedOrders = LocalStorageService.ordersRepo.getData();
      if (cachedOrders != null && cachedOrders.isNotEmpty) {
        final activeCached = cachedOrders
            .where((o) => o.status != OrderStatus.delivered)
            .toList();
        yield right(activeCached.map((e) => e.toEntity()).toList());
      } else {
        yield left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, void>> saveOrder(
      OrderModel order, String userId) async {
    try {
      final docRef =
      _db.collection('users').doc(userId).collection('Orders').doc();

      final orderWithId = order.copyWithId(docRef.id);
      await docRef.set(orderWithId.toJson());

      final cachedOrders = LocalStorageService.ordersRepo.getData() ?? [];
      cachedOrders.add(orderWithId);
      await LocalStorageService.ordersRepo.saveData(cachedOrders);

      return const Right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOrder(String orderId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isNotEmpty) {
        await _db
            .collection('users')
            .doc(userId)
            .collection('Orders')
            .doc(orderId)
            .delete();
      }

      final cachedOrders = LocalStorageService.ordersRepo.getData() ?? [];
      cachedOrders.removeWhere((o) => o.id == orderId);
      await LocalStorageService.ordersRepo.saveData(cachedOrders);

      return const Right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}