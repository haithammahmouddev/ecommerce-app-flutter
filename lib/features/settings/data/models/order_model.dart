import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/entities/order_entity.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/helper_functions.dart';
import 'address_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final OrderStatus status;
  final double totalAmount;
  final DateTime orderDate;
  final String paymentMethod;
  final AddressModel? address;
  final DateTime? deliveryDate;
  final List<CartItemModel> items;

  OrderModel({
    required this.id,
    this.userId = '',
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.paymentMethod = 'Paypal',
    this.address,
    this.deliveryDate,
  });

  String get formattedOrderDate => HelperFunctions.getFormattedDate(orderDate);

  String get formattedDeliveryDate =>
      deliveryDate != null ? HelperFunctions.getFormattedDate(deliveryDate!) : '';

  String get orderStatusText {
    switch (status) {
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.shipped:
        return 'Shipment on the way';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.cancelled:
        return 'Order Rejected';
      case OrderStatus.pending:
      return 'Pending Approval';
    }
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      userId: userId,
      status: status,
      totalAmount: totalAmount,
      orderDate: orderDate,
      paymentMethod: paymentMethod,
      address: address?.toEntity(),
      deliveryDate: deliveryDate,
      items: items.map((item) => item.toEntity()).toList(),
    );
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      status: entity.status,
      totalAmount: entity.totalAmount,
      orderDate: entity.orderDate,
      paymentMethod: entity.paymentMethod,
      address: entity.address != null ? AddressModel.fromEntity(entity.address!) : null,
      deliveryDate: entity.deliveryDate,
      items: entity.items.map((itemEntity) => CartItemModel.fromEntity(itemEntity)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'status': status.toString(),
      'totalAmount': totalAmount,
      'orderDate': orderDate,
      'paymentMethod': paymentMethod,
      'address': address?.toJson(),
      'deliveryDate': deliveryDate,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return OrderModel(
        id: '',
        status: OrderStatus.pending,
        items: [],
        totalAmount: 0.0,
        orderDate: DateTime.now(),
      );
    }

    DateTime _parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    OrderStatus _parseStatus(String? statusStr) {
      return OrderStatus.values.firstWhere(
            (e) => e.toString() == statusStr || e.name == statusStr,
        orElse: () => OrderStatus.pending,
      );
    }

    return OrderModel(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      userId: (json['userId'] ?? json['userId'] ?? '').toString(),
      status: _parseStatus(json['status'] ?? json['Status']),
      totalAmount: (json['totalAmount'] ?? json['TotalAmount'] ?? 0.0 as num).toDouble(),
      orderDate: _parseDate(json['orderDate'] ?? json['OrderDate']),
      paymentMethod: (json['paymentMethod'] ?? json['PaymentMethod'] ?? 'Paypal').toString(),
      address: json['address'] != null || json['Address'] != null
          ? AddressModel.fromMap((json['address'] ?? json['Address']) as Map<String, dynamic>)
          : null,
      deliveryDate: json['deliveryDate'] != null || json['DeliveryDate'] != null
          ? _parseDate(json['deliveryDate'] ?? json['DeliveryDate'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
          .map((itemData) => CartItemModel.fromJson(itemData as Map<String, dynamic>))
          .toList()
          : [],
    );
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OrderModel.fromJson(data).copyWithId(snapshot.id);
  }

  OrderModel copyWithId(String newId) {
    return OrderModel(
      id: newId,
      userId: userId,
      status: status,
      items: items,
      totalAmount: totalAmount,
      orderDate: orderDate,
      paymentMethod: paymentMethod,
      address: address,
      deliveryDate: deliveryDate,
    );
  }
}