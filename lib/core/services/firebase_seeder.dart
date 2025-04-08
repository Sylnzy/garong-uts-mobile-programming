// import 'package:firebase_database/firebase_database.dart';
// import '../../data/models/product_model.dart';

// class FirebaseSeeder {
//   static DatabaseReference get _database => FirebaseDatabase.instance.ref();


//   static Future<void> seedProducts() async {
//     try {
//       final productsRef = _database.child('products');
      
//       final products = [
//         ProductModel(
//           id: 'p1',
//           name: 'Beras 5kg',
//           description: 'Beras murni',
//           price: 75000,
//           imageUrl: 'https://via.placeholder.com/150',
//           stock: 100,
//           category: 'Food',
//         ),
//         ProductModel(
//           id: 'p2',
//           name: 'Minyak Goreng',
//           description: 'Minyak goreng berkualitas',
//           price: 28000,
//           imageUrl: 'https://via.placeholder.com/150',
//           stock: 200,
//           category: 'Food',
//         ),
//         ProductModel(
//           id: 'p3',
//           name: 'Mie Instan',
//           description: 'Mie instan lezat',
//           price: 3000,
//           imageUrl: 'https://via.placeholder.com/150',
//           stock: 300,
//           category: 'Food',
//         ),
//         ProductModel(
//           id: 'p4',
//           name: 'Kopi Sachet',
//           description: 'Kopi sachet nikmat',
//           price: 1500,
//           imageUrl: 'https://via.placeholder.com/150',
//           stock: 400,
//           category: 'Beverage',
//         ),
//       ];

//       // Add products to database using their IDs
//       for (var product in products) {
//         await productsRef.child(product.id).set(product.toRTDB());
//         print('Added product: ${product.name}');
//       }

//       print('Successfully seeded all products');
//     } catch (e) {
//       print('Error seeding products: $e');
//       rethrow;
//     }
//   }

//   // Method to verify products were added
//   static Future<void> verifyProducts() async {
//     try {
//       final snapshot = await _database.child('products').get();
//       if (snapshot.exists) {
//         print('Total products in database: ${snapshot.children.length}');
//         snapshot.children.forEach((child) {
//           final data = child.value as Map<dynamic, dynamic>;
//           print('Product: ${data['name']} - ${data['price']}');
//         });
//       } else {
//         print('No products found in database');
//       }
//     } catch (e) {
//       print('Error verifying products: $e');
//     }
//   }
// }