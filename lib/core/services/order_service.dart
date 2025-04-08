import 'package:flutter/material.dart';
import '/providers/cart_provider.dart';

class OrderService {
  // Local storage of orders for demo purposes
  static final List<Map<String, dynamic>> _orders = [];

  static Future<void> saveOrder({
    required String orderId,
    required int amount,
    required List<CartItem> items,
    required Map<String, dynamic> buyerData,
  }) async {
    try {
      // Create order data
      final orderData = {
        'orderId': orderId,
        'userId': 'demo-user',
        'amount': amount,
        'date': DateTime.now().millisecondsSinceEpoch,
        'status': 'completed',
        'buyerData': buyerData,
        'items':
            items
                .map(
                  (item) => {
                    'id': item.id,
                    'title': item.title,
                    'price': item.price,
                    'quantity': item.quantity,
                  },
                )
                .toList(),
      };

      // Add to local storage
      _orders.add(orderData);

      debugPrint('Order saved successfully: $orderId');
    } catch (e) {
      debugPrint('Error saving order: $e');
      throw Exception('Gagal menyimpan pesanan: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getOrderHistory() async {
    try {
      // Return the stored orders
      return _orders;
    } catch (e) {
      debugPrint('Error getting order history: $e');
      return [];
    }
  }
}
