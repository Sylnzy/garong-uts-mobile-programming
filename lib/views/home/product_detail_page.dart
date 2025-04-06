import 'package:flutter/material.dart';
import '/data/models/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

  void increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.network(product.imageUrl, height: 200),
            const SizedBox(height: 16),
            Text(product.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Rp ${product.price.toStringAsFixed(0)}", style: TextStyle(fontSize: 20, color: Colors.orange)),
            const SizedBox(height: 16),
            Text(product.description),
            const SizedBox(height: 20),

            // Quantity Control
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: decreaseQuantity,
                ),
                Text('$quantity', style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: increaseQuantity,
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                // nanti kita sambung ke keranjang
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Ditambahkan ${product.name} x$quantity ke keranjang")),
                );
              },
              icon: Icon(Icons.add_shopping_cart),
              label: Text("Tambahkan ke Keranjang"),
            ),
          ],
        ),
      ),
    );
  }
}
