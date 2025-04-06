// lib/data/models/product_model.dart
class ProductModel {
  final String name;
  final double price;
  final String imageUrl;

  ProductModel({
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

List<ProductModel> dummyProducts = [
  ProductModel(name: 'Beras 5kg', price: 75000, imageUrl: 'https://via.placeholder.com/150'),
  ProductModel(name: 'Minyak Goreng', price: 28000, imageUrl: 'https://via.placeholder.com/150'),
  ProductModel(name: 'Mie Instan', price: 3000, imageUrl: 'https://via.placeholder.com/150'),
  ProductModel(name: 'Kopi Sachet', price: 1500, imageUrl: 'https://via.placeholder.com/150'),
];
