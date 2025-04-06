import '/data/models/cart_item_model.dart';

class Order {
  final String orderId;
  final DateTime date;
  final List<CartItem> items;
  final CustomerData customerData;
  final DeliveryInfo deliveryInfo;
  final PaymentInfo paymentInfo;

  const Order({
    required this.orderId,
    required this.date,
    required this.items,
    required this.customerData,
    required this.deliveryInfo,
    required this.paymentInfo,
  });

  int get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice.toInt());
  int get total => subtotal + deliveryInfo.fee - paymentInfo.discount;
}

class CustomerData {
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String? notes;

  const CustomerData({
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.notes,
  });
}

class DeliveryInfo {
  final bool isDelivery;
  final int fee;
  final String? address;

  const DeliveryInfo({
    required this.isDelivery,
    required this.fee,
    this.address,
  });
}

class PaymentInfo {
  final int amount;
  final int discount;
  final String? couponCode;
  final DateTime paymentDate;
  final String paymentMethod;

  const PaymentInfo({
    required this.amount,
    required this.discount,
    this.couponCode,
    required this.paymentDate,
    required this.paymentMethod,
  });
}
