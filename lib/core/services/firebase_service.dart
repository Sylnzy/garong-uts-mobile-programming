import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart'; // Added this import for debugPrint
import '../../data/models/product_model.dart';
import '/data/models/order_model.dart' as app_models;
import '../../data/models/user_model.dart';

class FirebaseService {
  static FirebaseService? _instance;
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _auth;
  late final DatabaseReference _database;

  // Private constructor
  FirebaseService._() {
    // Initialize instances without re-initializing Firebase
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _database = FirebaseDatabase.instance.ref();

    // Ensure the database URL is set correctly
    if (FirebaseDatabase.instance.databaseURL !=
        'https://garong-app-default-rtdb.asia-southeast1.firebasedatabase.app') {
      debugPrint('Warning: Database URL mismatch, resetting to correct URL');
      FirebaseDatabase.instance.databaseURL =
          'https://garong-app-default-rtdb.asia-southeast1.firebasedatabase.app';
    }
  }

  // Singleton instance
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  // Products
  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Products - Realtime Database
  Stream<List<ProductModel>> getProductsStream() {
    print('Initializing products stream...'); // Debug print
    return _database.child('products').onValue.map((event) {
      print(
        'Received data from Firebase: ${event.snapshot.value}',
      ); // Debug print

      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) {
        print('No data available'); // Debug print
        return [];
      }

      try {
        final products =
            data.entries.map((e) {
              final Map<String, dynamic> productData =
                  Map<String, dynamic>.from(e.value as Map);
              print(
                'Processing product: ${productData['name']}',
              ); // Debug print
              return ProductModel.fromRTDB(productData, e.key);
            }).toList();

        print('Processed ${products.length} products'); // Debug print
        return products;
      } catch (e) {
        print('Error processing products: $e'); // Debug print
        return [];
      }
    });
  }

  Future<void> addProduct(ProductModel product) async {
    await _database.child('products').push().set(product.toRTDB());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _database
        .child('products')
        .child(product.id)
        .update(product.toRTDB());
  }

  Future<void> deleteProduct(String productId) async {
    await _database.child('products').child(productId).remove();
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'stock': newStock});
    } catch (e) {
      print('Error updating stock: $e');
      throw e;
    }
  }

  Future<void> decreaseStock(String productId, int quantity) async {
    final ref = _database.child('products').child(productId);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      throw Exception('Product not found');
    }

    final currentStock = snapshot.child('stock').value as int? ?? 0;

    if (currentStock < quantity) {
      throw Exception('Insufficient stock');
    }

    await ref.update({'stock': currentStock - quantity});
  }

  // Orders
  Future<void> createOrder(app_models.Order order) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final orderData = {
      'userId': user.uid,
      'items':
          order.items
              .map(
                (item) => {
                  'productId': item.product.id,
                  'quantity': item.quantity,
                  'price': item.product.price,
                },
              )
              .toList(),
      'customerData': {
        'name': order.customerData.name,
        'email': order.customerData.email,
        'phone': order.customerData.phone,
        'address': order.customerData.address,
        'notes': order.customerData.notes,
      },
      'deliveryInfo': {
        'isDelivery': order.deliveryInfo.isDelivery,
        'fee': order.deliveryInfo.fee,
        'address': order.deliveryInfo.address,
      },
      'paymentInfo': {
        'amount': order.paymentInfo.amount,
        'discount': order.paymentInfo.discount,
        'couponCode': order.paymentInfo.couponCode,
        'paymentDate': order.paymentInfo.paymentDate.toIso8601String(),
        'paymentMethod': order.paymentInfo.paymentMethod,
      },
      'date': FieldValue.serverTimestamp(),
      'status': 'pending',
    };

    final orderRef = await _firestore.collection('orders').add(orderData);

    // Update user's order history
    await _firestore.collection('users').doc(user.uid).update({
      'orderHistory': FieldValue.arrayUnion([orderRef.id]),
    });
  }

  // User Profile
  Future<void> updateUserProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  /// Checks if the app is connected to Firebase Realtime Database
  Future<bool> checkDatabaseConnection() async {
    try {
      // Try to ping the database
      final connectionRef = FirebaseDatabase.instance.ref(".info/connected");
      final event = await connectionRef.once();

      // Log connection status
      final isConnected = event.snapshot.value as bool? ?? false;
      debugPrint(
        '📡 Firebase Realtime Database connection: ${isConnected ? "✅ CONNECTED" : "❌ DISCONNECTED"}',
      );

      // Additional verification by trying to read from the database
      final dbTest =
          await FirebaseDatabase.instance
              .ref()
              .child("products")
              .limitToFirst(1)
              .get();
      debugPrint(
        '🔍 Database test result: ${dbTest.exists ? "✅ Data exists" : "⚠️ No data"}',
      );

      if (dbTest.exists) {
        debugPrint('📦 Sample data: ${dbTest.children.first.key}');
      }

      // Print the database URL for verification
      debugPrint('🌐 Database URL: ${FirebaseDatabase.instance.databaseURL}');

      return isConnected && dbTest.exists;
    } catch (e) {
      debugPrint('❌ Database connection error: $e');
      return false;
    }
  }

  /// Try different database URLs to find one that works
  Future<String?> findWorkingDatabaseURL() async {
    final possibleURLs = [
      'https://garong-app-default-rtdb.asia-southeast1.firebasedatabase.app',
      'https://garong-app.firebasedatabase.app',
      'https://garong-app-default-rtdb.firebasedatabase.app',
    ];

    for (final url in possibleURLs) {
      try {
        debugPrint('Trying database URL: $url');
        FirebaseDatabase.instance.databaseURL = url;

        // Try to access the database
        final ref = FirebaseDatabase.instance.ref(".info/connected");
        final event = await ref.once();
        final isConnected = event.snapshot.value as bool? ?? false;

        if (isConnected) {
          debugPrint('✅ Working database URL found: $url');
          return url;
        }
      } catch (e) {
        debugPrint('Error with URL $url: $e');
      }
    }

    debugPrint('❌ No working database URL found');
    return null;
  }
}
