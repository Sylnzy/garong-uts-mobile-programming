// lib/data/models/product_model.dart
class ProductModel {
  final String name;
  final String imageUrl;
  final String description;
  final double price;

  ProductModel({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.price,
  });
}


List<ProductModel> dummyProducts = [
  ProductModel(name: 'Beras 5kg',description: 'Beras murni', price: 75000, imageUrl: 'https://via.placeholder.com/150'),
  ProductModel(name: 'Minyak Goreng', description: 'Minyak goreng berkualitas', price: 28000, imageUrl: 'https://via.placeholder.com/150'),
  ProductModel(name: 'Mie Instan', description: 'Mie instan lezat', price: 3000, imageUrl: 'https://via.placeholder.com/150'),
  ProductModel(name: 'Kopi Sachet', description: 'Kopi sachet nikmat', price: 1500, imageUrl: 'https://via.placeholder.com/150'),
];
