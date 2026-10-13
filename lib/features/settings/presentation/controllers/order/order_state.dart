import 'package:equatable/equatable.dart';
import 'package:fit_store/features/auth/domain/entities/order_entity.dart';

enum OrderStatusEnum { initial, loading, success, error, processingSuccess }

class OrderState extends Equatable {
  final OrderStatusEnum status;
  final List<OrderEntity> orders;
  final String? errorMessage;

  const OrderState({
    this.status = OrderStatusEnum.initial,
    this.orders = const [],
    this.errorMessage,
  });

  OrderState copyWith({
    OrderStatusEnum? status,
    List<OrderEntity>? orders,
    String? errorMessage,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, errorMessage];
}