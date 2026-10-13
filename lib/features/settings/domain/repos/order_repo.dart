import 'package:dartz/dartz.dart';
import '../../../../common/errors/failure.dart';
import '../../../auth/domain/entities/order_entity.dart';
import '../../data/models/order_model.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> fetchUserOrders();

  Stream<Either<Failure, List<OrderEntity>>> fetchUserOrdersStream();

  Future<Either<Failure, void>> saveOrder(OrderModel order, String userId);
  Future<Either<Failure, void>> deleteOrder(String orderId);
}