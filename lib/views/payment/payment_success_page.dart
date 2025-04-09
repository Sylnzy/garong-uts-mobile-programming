import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/cart_provider.dart';
import '/core/services/order_service.dart';
import 'package:firebase_database/firebase_database.dart';
import '/data/models/product_model.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String orderId;
  final int amount;
  final Map<String, dynamic> buyerData;

  const PaymentSuccessPage({
    super.key, // Perbaikan: gunakan super.key, bukan Key? key
    required this.orderId,
    required this.amount,
    required this.buyerData,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _isSaving = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _saveOrderData();
  }

  Future<void> _saveOrderData() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      // Menyimpan pesanan ke Firebase
      await OrderService.saveOrder(
        orderId: widget.orderId,
        amount: widget.amount,
        items: cartProvider.items.values.toList(),
        buyerData: widget.buyerData,
      );

      // Mengurangi stock untuk setiap item dalam keranjang
      await _decreaseProductsStock(cartProvider);

      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString();
      });
      debugPrint('Error saving order: $e');
    }
  }

  // Tambahkan method baru untuk mengurangi stock
  Future<void> _decreaseProductsStock(CartProvider cartProvider) async {
    for (final productId in cartProvider.items.keys) {
      final item = cartProvider.items[productId]!;
      try {
        // Ambil referensi database untuk mengakses model produk
        final dbRef = FirebaseDatabase.instance
            .ref()
            .child('products')
            .child(productId);
        final snapshot = await dbRef.get();

        // Pastikan produk ditemukan
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          final productModel = ProductModel.fromRTDB(
            Map<String, dynamic>.from(data),
            productId,
          );

          // Gunakan method decreaseStock dari ProductModel
          await productModel.decreaseStock(item.quantity);
          debugPrint(
            'Stock berkurang untuk produk ${item.title}, jumlah: ${item.quantity}',
          );
        } else {
          debugPrint('Produk tidak ditemukan: $productId');
        }
      } catch (e) {
        debugPrint('Error mengurangi stock: $e');
        // Anda bisa memutuskan apakah ingin throw exception ini atau tidak
        // throw e;
      }
    }

    // Bersihkan keranjang setelah semua stock berhasil diperbarui
    cartProvider.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Berhasil'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              _isSaving
                  ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.green),
                      SizedBox(height: 20),
                      Text("Menyimpan data pesanan..."),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_errorMessage.isNotEmpty) ...[
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Terjadi kesalahan: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                      ],
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 100,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Pembayaran Telah Dikonfirmasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Order ID: ${widget.orderId}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Nama: ${widget.buyerData['nama']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Jumlah: Rp ${widget.amount}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                        ),
                        onPressed: () {
                          // Clear the cart after successful payment
                          Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).clearCart();

                          // Lihat riwayat pesanan
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/history',
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Lihat Riwayat Pesanan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Clear the cart after successful payment
                          Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).clearCart();

                          // Navigate to the home page using the correct route '/'
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (route) => false);
                        },
                        child: const Text(
                          'Kembali ke Beranda',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
