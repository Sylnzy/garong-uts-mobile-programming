import 'package:flutter/material.dart';

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

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  int get totalAmount {
    int total = 0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addItem(String productId, String title, int price, [int quantity = 1]) {
  if (_items.containsKey(productId)) {
    _items.update(
      productId,
      (existingItem) => existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      ),
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


  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => existingItem.copyWith(
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      removeItem(productId);
    }
    notifyListeners();
  }
}
