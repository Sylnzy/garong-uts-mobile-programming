import 'package:flutter/material.dart';
import '/data/models/product_model.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          // Product details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${NumberFormat('#,###').format(product.price)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok: ${product.stock}',
                  style: TextStyle(
                    color: product.stock > 0 ? Colors.black54 : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
