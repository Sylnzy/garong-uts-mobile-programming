// lib/data/models/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final double price;
  final int stock;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
  });

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
    };
  }

  factory ProductModel.fromRTDB(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toRTDB() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
    };
  }

  // Change updateStock method to use Realtime Database
  Future<void> updateStock(int newStock) async {
    await FirebaseDatabase.instance.ref().child('products').child(id).update({
      'stock': newStock,
    });
  }

  // Add a method to decrease stock
  Future<void> decreaseStock(int quantity) async {
    final ref = FirebaseDatabase.instance.ref().child('products').child(id);

    final snapshot = await ref.get();
    final currentStock = snapshot.child('stock').value as int? ?? 0;

    if (currentStock < quantity) {
      throw Exception('Insufficient stock');
    }

    await ref.update({'stock': currentStock - quantity});
  }
}

// List<ProductModel> dummyProducts = [
//   ProductModel(
//     id: 'p1',
//     name: 'Beras 5kg',
//     description: 'Beras murni',
//     price: 75000,
//     imageUrl: 'https://via.placeholder.com/150',
//     stock: 100,
//     category: 'Food',
//   ),
//   ProductModel(
//     id: 'p2',
//     name: 'Minyak Goreng',
//     description: 'Minyak goreng berkualitas',
//     price: 28000,
//     imageUrl: 'https://via.placeholder.com/150',
//     stock: 200,
//     category: 'Food',
//   ),
//   ProductModel(
//     id: 'p3',
//     name: 'Mie Instan',
//     description: 'Mie instan lezat',
//     price: 3000,
//     imageUrl: 'https://via.placeholder.com/150',
//     stock: 300,
//     category: 'Food',
//   ),
//   ProductModel(
//     id: 'p4',
//     name: 'Kopi Sachet',
//     description: 'Kopi sachet nikmat',
//     price: 1500,
//     imageUrl: 'https://via.placeholder.com/150',
//     stock: 400,
//     category: 'Beverage',
//   ),
// ];
