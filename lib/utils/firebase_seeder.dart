// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../data/models/product_model.dart';

// class FirebaseSeeder {
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   static Future<void> seedProducts() async {
//     try {
//       final batch = _firestore.batch();
//       final productsRef = _firestore.collection('products');

//       // First, check if products already exist
//       final existingProducts = await productsRef.get();
//       if (existingProducts.docs.isNotEmpty) {
//         print('Products already exist in database');
//         return;
//       }

//       // Add each dummy product to batch
//       for (var product in dummyProducts) {
//         final docRef = productsRef.doc(product.id);
//         batch.set(docRef, product.toFirestore());
//       }

//       // Commit the batch
//       await batch.commit();
//       print('Successfully seeded ${dummyProducts.length} products');
//     } catch (e) {
//       print('Error seeding products: $e');
//     }
//   }

//   static Future<void> verifyProducts() async {
//     try {
//       final querySnapshot = await _firestore.collection('products').get();
//       print('Total products in database: ${querySnapshot.docs.length}');

//       for (var doc in querySnapshot.docs) {
//         print('Product: ${doc.data()['name']} - ${doc.data()['price']}');
//       }
//     } catch (e) {
//       print('Error verifying products: $e');
//     }
//   }
// }
