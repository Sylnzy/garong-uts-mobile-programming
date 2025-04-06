import '/data/models/product_model.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  int get totalPrice => product.price * quantity;
}
