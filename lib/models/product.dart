class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      stock: data['stock'] ?? 0,
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Add method to convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  // Add method to update stock
  Product copyWith({int? newStock}) {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      stock: newStock ?? stock,
      category: category,
      imageUrl: imageUrl,
    );
  }
}
