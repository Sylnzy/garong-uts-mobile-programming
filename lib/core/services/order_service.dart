import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '/providers/cart_provider.dart';
import '/data/models/order_model.dart';

class OrderService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Simpan order ke Firebase Realtime Database
  static Future<void> saveOrder({
    required String orderId,
    required int amount,
    required List<CartItem> items,
    required Map<String, dynamic> buyerData,
  }) async {
    try {
      // Pastikan user sudah login
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Buat data order
      final orderData = {
        'orderId': orderId,
        'userId': user.uid,
        'amount': amount,
        'date': DateTime.now().millisecondsSinceEpoch,
        'status': 'completed',
        'buyerData': buyerData, // Ini berisi isDelivery, alamat, dll
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

      // Simpan ke database - menggunakan path orders/{userId}/{orderId}
      final orderRef = _database
          .ref()
          .child('orders')
          .child(user.uid)
          .child(orderId);
      await orderRef.set(orderData);

      debugPrint('Order saved successfully to Firebase: $orderId');
    } catch (e) {
      debugPrint('Error saving order: $e');
      throw Exception('Gagal menyimpan pesanan: $e');
    }
  }

  // Ambil history order dari Firebase
  static Future<List<Map<String, dynamic>>> getOrderHistory() async {
    try {
      // Pastikan user sudah login
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Ambil data order dari Firebase berdasarkan userId
      final snapshot =
          await _database.ref().child('orders').child(user.uid).get();

      if (snapshot.exists) {
        final ordersData = snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> ordersList = [];

        ordersData.forEach((key, value) {
          final orderData = Map<String, dynamic>.from(
            value as Map<dynamic, dynamic>,
          );
          ordersList.add(orderData);
        });

        // Urutkan berdasarkan tanggal terbaru
        ordersList.sort(
          (a, b) => (b['date'] as int).compareTo(a['date'] as int),
        );

        return ordersList;
      }
      return [];
    } catch (e) {
      debugPrint('Error getting order history: $e');
      return [];
    }
  }

  // Method untuk mendapatkan detail order berdasarkan ID
  static Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      // Pastikan user sudah login
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      final snapshot =
          await _database
              .ref()
              .child('orders')
              .child(user.uid)
              .child(orderId)
              .get();

      if (snapshot.exists) {
        return Map<String, dynamic>.from(
          snapshot.value as Map<dynamic, dynamic>,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting order detail: $e');
      return null;
    }
  }
}
