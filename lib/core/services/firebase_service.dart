import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../data/models/product_model.dart';
import '/data/models/order_model.dart' as app_models;
import '../../data/models/user_model.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static late final FirebaseFirestore _firestore;
  static late final FirebaseAuth _auth;
  static late final DatabaseReference _database;

  // Private constructor
  FirebaseService._() {
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _database = FirebaseDatabase.instance.ref();
  }

  // Singleton instance
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  // Initialize Firebase
  static Future<void> initialize() async {
    if (_instance == null) {
      _instance = FirebaseService._();
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    }
  }

  // Products
  static Future<List<ProductModel>> getProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Products - Realtime Database
  static Stream<List<ProductModel>> getProductsStream() {
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

  static Future<void> addProduct(ProductModel product) async {
    await _database.child('products').push().set(product.toRTDB());
  }

  static Future<void> updateProduct(ProductModel product) async {
    await _database
        .child('products')
        .child(product.id)
        .update(product.toRTDB());
  }

  static Future<void> deleteProduct(String productId) async {
    await _database.child('products').child(productId).remove();
  }

  static Future<void> updateProductStock(String productId, int newStock) async {
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

  static Future<void> decreaseStock(String productId, int quantity) async {
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
  static Future<void> createOrder(app_models.Order order) async {
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
  static Future<void> updateUserProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  static Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc.data()!, doc.id);
  }
}
