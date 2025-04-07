import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '/data/models/coupon.dart';

import '/core/services/firebase_service.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final int price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      title: title,
      quantity: quantity ?? this.quantity,
      price: price,
    );
  }
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final _logger = Logger('CartProvider');

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  int get totalAmount {
    int total = 0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  @override
  void addItem(String productId, String title, int price, [int quantity = 1]) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingItem) =>
            existingItem.copyWith(quantity: existingItem.quantity + quantity),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          quantity: quantity,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  @override
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  @override
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  @override
  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) =>
            existingItem.copyWith(quantity: existingItem.quantity - 1),
      );
    } else {
      removeItem(productId);
    }
    notifyListeners();
  }

  Coupon? _appliedCoupon;

  Coupon? get appliedCoupon => _appliedCoupon;

  @override
  void applyCoupon(String code) {
    final coupon = availableCoupons.firstWhere(
      (c) => c.code == code,
      orElse: () => Coupon(code: '', discount: 0.0),
    );

    if (coupon.code.isNotEmpty) {
      _appliedCoupon = coupon;
    } else {
      _appliedCoupon = null;
    }
    notifyListeners();
  }

  double get discountAmount {
    if (_appliedCoupon != null) {
      return (totalAmount * _appliedCoupon!.discount) / 100;
    }
    return 0.0;
  }

  double get finalTotal {
    return totalAmount + _deliveryFee - discountAmount;
  }

  final double _deliveryFee = 50.0;

  Future<void> checkout() async {
    try {
      for (var item in _items.values) {
        await FirebaseService.decreaseStock(item.id, item.quantity);
      }
      clearCart();
    } catch (e) {
      _logger.severe('Error during checkout: $e');
      rethrow;
    }
  }
}
